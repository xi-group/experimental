#!/bin/bash -e

export REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s/.$//g)
export I_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
source /etc/lsb-release

export DEBIAN_FRONTEND=noninteractive

apt_get_install()
{
    # Address race condition
    APT_RUNNING=$(ps -ax | egrep "apt|dpkg" | grep -v grep | wc -l)
    while [ "$APT_RUNNING" -gt 0 ]; do
        echo "$(date) dpkg is locked trying again..."
        sleep 1
        APT_RUNNING=$(ps -ax | egrep "apt|dpkg" | grep -v grep | wc -l)
    done

	DEBIAN_FRONTEND=noninteractive apt-get -y \
       -o DPkg::Options::=--force-confnew \
       install $@
}

apt update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confnew" dist-upgrade

apt_get_install apt-transport-s3 unzip dstat tree traceroute whois

# install awscli v2
curl -s --retry 3 --retry-delay 20 --retry-max-time 3 "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -u -q -d /tmp/awscli /tmp/awscliv2.zip # quiet mode extract files in /tmp/awscli
/tmp/awscli/aws/install

# end of user_data
