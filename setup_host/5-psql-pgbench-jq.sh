#!/bin/bash


if [ -z $SUDO_USER ]; then
    echo "Script MUST be executed with 'sudo'"
    echo "Aborting!!!"
    exit 0
fi

# March 17, 2024 : Changed to v14.11 (from 13)
# CHANGE THE Version to 14 otherwise psql will misbehave !!!
echo "Installing the postgresql14 tools"
amazon-linux-extras install postgresql14 vim epel -y

echo "Install the pgbench"
yum install postgresql-contrib -y

echo "Install jq"
sudo yum install -y jq


echo "Done"
