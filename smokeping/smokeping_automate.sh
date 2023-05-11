#!/bin/bash

# This script is builded for updating Smokeping config file "Targets".The code is separated on two functionalities and it is assumed that it should work with crontab.

# First functionality:
# 1.Create the file if dosen't exist in s3 or local.
# 2.Make a query to te database "aux" to get the input files. Inputs files should looks like this: hostname,name,active,authorized. Do a while loop throught every input line.
# 3.It's do some checks, whether hostname active and authorized, whether hostname is ccr or vid, whether is the right block.
# 4.Upload to s3 the generated config file named "New_Targets"
# Second functionality:
# 1.Download the config file New_Targets from s3 bucket.
# 2.We compare the both files New_Targets and Targets, if are some diffrents then apply and restart smokeping service.

# EXAMPLE USAGE
# ./smokeping_automate.sh -u your_username -p your_password -a dbhost -d dbname


# Define s3 bucket path
s3_bucket_path_current_file=s3://cn-ops/smokeping/current
s3_bucket_path_backups_file=s3://cn-ops/smokeping/backups/$(date +%Y)/$(date +%m)/$(date +%d)

# Check if file dosen't exist in s3 or local.
if [ ! -f "/etc/smokeping/config.d/New_Targets" ] && [ -z "$(aws s3 ls "s3://${s3_bucket_path_current_file}/New_Targets" --quiet)" ]; then

# Define output file
output_file="/etc/smokeping/config.d/New_Targets"
touch "${output_file}"

# Define Targets file
targets_file="/etc/smokeping/config.d/Targets"

# Create the header of the Targets file
cat << EOF > ${output_file}
*** Targets ***
probe = FPing
menu = Top
title = Network Latency Grapher
remark = Welcome to the SmokePing website of Inscape Company. 
         Here you will learn all about the latency of our Ingest network.
EOF

# Define variable that keep block
current_block=""

# Set an empty array to hold processed hostnames
processed=()

RET_CODE_ERROR=1

# Help/Usage function
print_help() {
	echo "$0: Usage"
	echo "    [-h] Print help"
	echo "    [--username|-u] (MANDATORY) DB Username"
	echo "    [--password|-p] (MANDATORY) DB Password"
	echo "    [--host|-a] (MANDATORY) DB Hostname"
	echo "    [--database|-d] (MANDATORY) DB Name"
	echo "    [--sql-query|-q] (MANDATORY) SQL Query"
}

# Parse command line arguments
while [[ $# -gt 0 ]]
do
	case "$1" in
		--help|-h)
			print_help
			exit $RET_CODE_ERROR
			;;
		--username|-u)
			USERNAME=$2
			shift
			;;
		--password|-p)
			PASSWORD=$2
			shift
			;;
		--host|-a)
			HOST=$2
			shift
			;;
		--database|-d)
			DB=$2
			shift
			;;
		--sql-query|-q)
			VALID_SQL=$2
			shift
			;;
		*)
			echo "$0: Unknown Argument: $1"
			print_help
			exit $RET_CODE_ERROR
			;;
	esac

	shift
done

# Check mandatory parameters
if [ -z "$USERNAME" -o -z "$PASSWORD" -o -z "$HOST" -o -z "$DB" ]; then
	echo "$0: Mandatory parameter missing!"
	print_help
	exit $RET_CODE_ERROR
fi

# Get database input
VALID_SQL="SELECT DISTINCT (d.hostname), e.name as name, c.active, c.authorized FROM inputs AS c, server AS d, site AS e WHERE c.server_id=d.server_id AND d.site_id=e.site_id AND c.active = 1 ORDER BY d.hostname;"

# Executing query to database
RESULT=$(mysql -N -B -u "$USERNAME" -p "$PASSWORD" -h "$HOST" -D "$DB" -e "$VALID_SQL")

while read -r line; do
  # Do something with each line of the result


    # Extract hostname index and two last digits
    values="$(  awk '{print $(NF-1), $NF}' <<< "$line")"

    # Check if this line contains a valid host entry
    if [ "$values" == "1 1" ]; then
       # Extract the hostname and name of the host
       hostname=$(echo $line | awk -F' ' '{print $1}')
       name=$(echo ${line%?????} | awk -F' ' '{print $2,$3,$4,$5,$6,$7}')
        # Check if hostname starts with "ccr" or "vid" and has not been processed already
        if [[ "${hostname:0:3}" == "ccr" ]] && [[ ! " ${processed[@]} " =~ " ${hostname:0:3} " ]]; then
            # Add hostname to the processed array
            processed+=("${hostname:0:3}")
            cat << EOF >> ${output_file}

+ ${processed[0]^^}
menu = ${processed[0]^^} Network
title = ${processed[0]^^} Ingest Servers Network
#parents = owner:/Test/James location:/
EOF

       elif [[ "${hostname:0:3}" == "vid" ]] && [[ ! " ${processed[@]} " =~ " ${hostname:0:3} " ]]; then
               # Add hostname to the processed array
               processed+=("${hostname:0:3}")
               ingest_name=${name:0:7}
               cat << EOF >> ${output_file}


########################################
#                                      #
#   Vidvita Network                    #
#                                      #
########################################

+ ${ingest_name}
menu = ${ingest_name} Network
title = ${ingest_name} Ingest Network
EOF

        fi

        # Extract the first 8 characters of the hostname to create the short line
        short_line=${hostname:0:8}
        # Check if the last character of the short line is a dash
        if [[ ${hostname:7:1} == "-" ]]; then
            # If it is, extract only the first 7 characters of the hostname to create the short line
            short_line=${hostname:0:7}
        fi

        # Check if we are in a new block
        if [[ "$current_block" != "$short_line" ]] && [[ "${short_line: -3}" != "${current_block: -3}" ]]; then
            # If we are, create a new section for the current host block
            # Store title in a variable
            title="${name} Ingest Network"
            # Remove extra spaces using sed
            title=$(echo "${title}" | sed 's/[[:space:]]\+/ /g')
            # Create a new section for the current host
            cat << EOF >> ${output_file}
++ ${short_line^^}
menu = ${name}
title = ${title}
EOF
            # Update the current block name
            current_block="$short_line"
        fi

        # Add the host entry to the current section
        cat << EOF >> ${output_file}
+++ ${hostname}
menu = ${hostname}
title = ${hostname}
host = ${hostname}-ext.cognet.tv
alerts = rttdetect,hostdown
EOF
    fi
done <<< "$RESULT"

echo "File: $(basename "${output_file}") generated successfully at ${output_file}."

# Upload file to S3
aws s3 cp "/etc/smokeping/config.d/New_Targets" "${s3_bucket_path_current_file}/New_Targets"
echo "File: $(basename "${output_file}") succesfully was uploaded to "${s3_bucket_path_current_file}/""

else
    # Download file from S3
    aws s3 cp "${s3_bucket_path_current_file}/New_Targets" "/etc/smokeping/config.d/New_Targets"
    echo "File: New_Targets was download from: "${s3_bucket_path_current_file}/""

    if diff /etc/smokeping/config.d/New_Targets /etc/smokeping/config.d/Targets > /dev/null ; then
        echo "Files are same"
    else
        echo "Files are different"
        echo "Make a backup of old Targets file"

        # Make a backup and upload it to s3 bucket
        bkp_file="/etc/smokeping/config.d/Targets_backup_$(date +%s)"
        cp /etc/smokeping/config.d/Targets ${bkp_file}
        aws s3 cp "${bkp_file}" "${s3_bucket_path_backups_file}/"
        echo "File: Targets_backup succesfully was uploaded to ${s3_bucket_path_backups_file}/"
        # Replace Targets file with the new data from New_Targets
        cp /etc/smokeping/config.d/New_Targets /etc/smokeping/config.d/Targets
        echo "Restarting smokeping service"
        sudo systemctl restart smokeping
    fi
fi
