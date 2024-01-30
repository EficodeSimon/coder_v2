#!/bin/bash

# Enable trace
set -x
exec 2>>/var/log/rce-init.log

whoami > /tmp/username.txt
echo "Start of user_data" > /tmp/user_data.log

# Updating package list
sudo apt-get update

# Installing postgres
sudo apt-get install -y postgresql-13

# Install AWS cli version 2
sudo apt-get install -y awscli

# Install nfs-common
sudo apt-get install -y nfs-common

# Creating directory for EFS
mkdir /mnt/efs

# Change permission for files in EFS. This could be done manually the first time
chown coder:coder /mnt/efs

# Depending on your needs you might want to change this.  This could also be done manually the first time
chmod 755 /mnt/efs

# Mounting EFS filesystem
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_dns_name}:/ /mnt/efs
echo "${efs_dns_name}:/ /mnt/efs nfs nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab



#Configure env for workspaces
sed -i 's#CODER_ACCESS_URL=#CODER_ACCESS_URL=${web_url}#' '/etc/coder.d/coder.env'
sed -i 's#CODER_PG_CONNECTION_URL=\"postgres://coder:coder@localhost/coder?sslmode=disable\"#CODER_PG_CONNECTION_URL=\"postgres://${db_username}:${db_password}@${rds_endpoint}/coderrds?sslmode=disable\"#' "/etc/coder.d/coder.env"

# Configure the env.
echo export CODER_PG_CONNECTION_URL="postgres://${db_username}:${db_password}@${rds_endpoint}/coderrds?sslmode=disable" >> /etc/profile
echo export CODER_ACCESS_URL="${web_url}" >> /etc/profile

# Reboot the server
shutdown -r now