#!/bin/bash
# Script for deployment and configuration DxSpider Cluster
# Create By Yiannis Panagou, SV5FRI
# https://www.sv5fri.eu
# E-mail:sv5fri@gmail.com
# Version 1.12 - Last Modify 18/05/2022
#
#Change Log
#=====================================================================================================
# 08/02/2022 - 1.8 - Update script to support Debian 11 (bullseye) & Raspbian GNU/Linux 11 (bullseye)
# 08/02/2022 - 1.9 - Support Mojo installation
# 15/05/2022 - 1.10 - Fix bug installation package into RHEL8/CentOS8/Rocky8
# 18/05/2022 - 1.11 - Fix installation added curl package for all distributions
# 18/05/2022 - 1.12 - Minor fix packages to Debian / Raspbian distributions
#=====================================================================================================
#
# Script for update DxSpider Cluster to Mojo versión
# Kin EA3CV
# Change Log
#=====================================================================================================
# 06-12-2022 - 1.0 First version
#=====================================================================================================
#
#

message() {
	echo -e " "
	echo -e "==============================================================="
	echo -e "This update will make a Backup of the current DXSpider software"
	echo -e "in the /home/spider.backup directory"
	echo -e " "
	echo -e "The new installation will use sysop as the DXSpider user"
	echo -e "and as a group to which sysop belongs to spider."
	echo -e " "
	echo -e "The users, DB and configuration files will be maintained."
	echo -e " "
	echo -e "The new software will be defined as dxspider.service."
	echo -e " "
	echo -e "Only OS versions that have been verified will be supported."
	echo -e "==============================================================="
	echo -e " "
	read -n 1 -s -r -p $'Press any key to continue...'
	echo -e " "
	echo -e "==============================================================="
	echo -e "To continue with the update, press [U]"
	echo -e "If you want to restore the backup due to failed update, press [B]"
	echo -e "==============================================================="
	echo -e " "
	 echo -n "Please enter [U]pdate or [B]ackup: "
	chr="\""
	read UPBACK
	echo ${UPBACK}
	if [ "${UPBACK}" == "U" ]; then
		# Nothing, we continue ...
	elif [ "${UPBACK}" == "B" ]; then
		echo -e "Indicate the path where it should be restored (eg /home/sysop): "
		chr="\""
		read BCKPATH
		echo ${BCKPATH}
		su - sysop -c "rm -rf /home/sysop/spider"
		su - sysop -c "mv /home/spider.backup ${BCKPATH}"
		if [ -f "/usr/lib/systemd/system/dxspider.service.old" ]; then
			su - sysop -c "mv /usr/lib/systemd/system/dxspider.service.old /usr/lib/systemd/system/dxspider.service"
			su - sysop -c "systemctl enable dxspider"
			su - sysop -c "systemctl start dxspider"
		else
			echo -e "Ended process."
			echo -e "Bye!"
			exit 1			
		fi		
	else
		echo -e " "
		echo -e "Bye!"
		exit 1
	fi
}

# Check the script is being run by root user
check_run_user() {
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
}

# Function Check Distribution and Version
check_distro() {

        arch=$(uname -m)
        kernel=$(uname -r)
        if [ -f "/etc/os-release" ]; then
                distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
        elif [ -f "/etc/redhat-release" ]; then
                distroname=$(cat /etc/redhat-release)
        else
                distroname="$(uname -s) $(uname -r)"
        fi

        echo -e " "
        echo -e "==============================================================="
        echo -e "      Your OS distribution is ${distroname}"
        echo -e "=============================================================== "
        echo -e " "
        echo -e " "
        read -n 1 -s -r -p $'Press any key to continue...'
        echo -e " "

        if [ "${distroname}" == "CentOS Linux 7 (Core)" ]; then
                                install_epel_7
                                install_package_CentOS_7
                        elif [ "${distroname}" == "CentOS Linux 8 (Core)" ]; then
                                install_epel_8
                                install_package_CentOS_8
                        elif [ "${distroname}" == "Rocky Linux 8.5 (Green Obsidian)" ]; then
                                install_epel_8
                                install_package_CentOS_8
                        elif [ "${distroname}" == "Raspbian GNU/Linux 9 (stretch)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Debian GNU/Linux 9 (stretch)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Raspbian GNU/Linux 10 (buster)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Debian GNU/Linux 10 (buster)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Raspbian GNU/Linux 11 (bullseye)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Debian GNU/Linux 11 (bullseye)" ]; then
                                install_package_debian
                else
                        echo -e " "
                        echo -e "==============================================================="
                        echo -e "      Your OS distribution ${distroname} is not supported"
                        echo -e "=============================================================== "
                        echo -e " "
                        echo -e " "
            exit 1
        fi
}

## CentOS 7.x
#
install_epel_7() {
#Install epel repository
## RHEL/CentOS 7 64-Bit ##
# Update the system
    yum check-update ; yum -y update
# Install the additional package repository EPEL
    yum -y install epel-release
}

# Install extra packages for CentOS 7.x
install_package_CentOS_7() {
    echo -e "Starting Installation Dxspider Cluster"
    echo -e " "
# Update the system
    yum check-update ; yum -y update
# Install extra packages
    yum -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Digest-SHA1 perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-Digest-SHA perl-IO-Compress curl 
}

## CentOS 8.x
#
install_epel_8() {
#Install epel repository
   echo -e "Starting Installation Dxspider Cluster"
   echo -e " "
## RHEL/CentOS 8 64-Bit ##
# Update the system
    dnf makecache --refresh
    dnf check-update ; dnf -y update
# Install the additional package repository EPEL
    dnf -y install epel-release
}

# Install extra packages for CentOS 8.x
install_package_CentOS_8() {
# Update the system
	dnf check-update ; dnf -y update
# Install extra packages
	dnf -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-IO-Compress perl-Digest-SHA perl-Net-CIDR-Lite curl
}

## Debian & raspbian
#
install_package_debian() {
    echo -e "Starting Installation Dxspider Cluster"
    echo -e " "
# Update the system
    apt-get update ; apt-get -y upgrade
# Install extra packages
    apt-get -y install perl libtimedate-perl libnet-telnet-perl libcurses-perl libdigest-sha-perl libdata-dumper-simple-perl git libjson-perl libmojolicious-perl  libdata-structure-util-perl libmath-round-perl libev-perl libjson-xs-perl build-essential procps libnet-cidr-lite-perl curl
}


# Create User and group - Create Directory and Symbolic Link
check_if_exist_user() {
egrep -i "^sysop:" /etc/passwd;
    if [ $? -eq 0 ]; then
        echo "User Exists no created"
    else
        echo "User does not exist -- proceed to create user sysop"
        echo -e " "
        useradd -m -s /bin/bash sysop
        echo "Please enter password for sysop user"
        passwd sysop
   fi
}

check_if_exist_group() {
egrep -i "^spider" /etc/group;
    if [ $? -eq 0 ]; then
        echo "Group Exists"
    else
        echo "Group does not exist -- proceed to create spider group"
        groupadd -g 251 spider
fi
}

create_user_group() {

# Greate user
check_if_exist_user
echo -e " "
echo -e " "

# Create group
check_if_exist_group
echo -e " "
echo -e " "

# Add the users to the spider group
echo -e "Add the users (sysop and root) to the spider group"
echo -e " "
usermod -aG spider sysop
usermod -aG spider root

echo -e " "
echo -e " "
}

# Enter CallSign for cluster
 insert_cluster_call() {
 echo -n "Please enter CallSign for DxCluster: "
 chr="\""
 read DXCALL
 echo ${DXCALL}
 su - sysop -c "sed -i 's/mycall =.*/mycall = ${chr}${DXCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your CallSign
insert_call() {
 echo -n "Please enter your CallSign: "
 chr="\""
 read SELFCALL
 echo ${SELFCALL}
 su - sysop -c "sed -i 's/myalias =.*/myalias = ${chr}${SELFCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your Name
insert_name() {
 echo -n "Please enter your Name: "
 chr="\""
 read MYNAME
 echo ${MYNAME}
 su - sysop -c "sed -i 's/myname =.*/myname = ${chr}${MYNAME}${chr};/' /spider/local/DXVars.pm"
}

# Enter your E-mail
insert_email() {
 echo -n "Please enter your E-mail Address(syntax like your\@email.com): "
 chr="\""
 read EMAIL
 echo ${EMAIL}
 su - sysop -c "sed -i 's/myemail =.*/myemail = ${chr}${EMAIL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your mylocator
insert_locator() {
 echo -n "Please enter your Locator(Use Capital Letter): "
 chr="\""
 read MYLOCATOR
 echo ${MYLOCATOR}
 su - sysop -c "sed -i 's/mylocator =.*/mylocator = ${chr}${MYLOCATOR}${chr};/' /spider/local/DXVars.pm"
}

# Enter your myqth
insert_qth() {
 echo -n "Please enter your QTH(use comma without space): "
 chr="\""
 read MYQTH
 echo ${MYQTH}
 su - sysop -c "sed -i 's/myqth =.*/myqth = ${chr}${MYQTH}${chr};/' /spider/local/DXVars.pm"
}

# Export users
export_user() {
	touch /tmp/backup_users
	cat >> /tmp/backup_users <<EOL
export_user
EOL
	su - sysop -c "mkdir ${PATHDXS/cmd_import"
	su - sysop -c " mv /tmp/backup_users ${PATHDXS/cmd_import/backup_users"
 }

# Stop DXSpider
stop_dxspider() {
	echo -n "Stopping DXSpider..."
	su - sysop -c "systemctl stop dxspider"
	su - sysop -c "systemctl disable dxspider"
	su - sysop -c "mv /usr/lib/systemd/system/dxspider.service /usr/lib/systemd/system/dxspider.service.old"
	su - sysop -c "mv ${PATHDXS /home/spider.backup"
}

# Enter your actual path
actual_path() {
	echo -n "Please enter your actual path of DXSpider, eg /home/sysop/spider"
	chr="\""
	read PATHDXS
	echo ${PATHDXS}
}

install_spider() {
# Create symbolic links
ln -s /home/sysop/spider /spider
# Download Application dxspider with git
echo -e "Now starting to download application DxSpider"
echo -e " "
su - sysop -c "git clone git://scm.dxcluster.org/scm/spider"
#
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm EV Mojolicious JSON JSON::XS Data::Structure::Util Math::Round


echo -e " "
}

update_files() {
# Copy user files, DB, ...
	echo -n "Copying user files, DB, ..."
	su - sysop -c "mv ${PATHDXS /home/spider.backup"
	su - sysop -c "mkdir /home/sysop/spider"
	su - sysop -c "mkdir /home/sysop/spider/msg"
	su - sysop -c "mkdir /home/sysop/spider/local_data"
	su - sysop -c "mkdir /home/sysop/spider/cmd_import"

	if [ -f "/home/spider.backup/local_data" ]; then
		# Mojo
		su - sysop -c "cp -r /home/spider.backup/local_data/ /home/sysop/spider/local_data/"
	else
		# Master
		su - sysop -c "cp -r /home/spider.backup/data/ /home/sysop/spider/local_data/"
	fi

	if [ -f "/home/spider.backup/msg" ]; then
		su - sysop -c "cp -r /home/spider.backup/msg/ /home/sysop/spider/msg/"
	fi
	su - sysop -c "cp -r /home/spider.backup/filter/ /home/sysop/spider/filter/"
}

config_app(){
# Fix up permissions ( AS THE SYSOP USER )
echo "Fix up permissions"
echo -e " "
echo -e "Please use capital letters"
echo -e " "
#
#su - sysop -c "mkdir /home/sysop/spider/local_data"
su - sysop -c "cd /spider"
su - sysop -c "cd /spider ; git reset --hard"
su - sysop -c "cd /spider ; git pull"
su - sysop -c "cd /spider ; git checkout --track -b mojo origin/mojo"
ln -s /spider/perl/console.pl /usr/local/bin/dx
ln -s /spider/perl/*dbg /usr/local/bin
#
su - sysop -c "cd /home/sysop"
su - sysop -c "chown -R sysop.spider spider"
su - sysop -c "find ./ -type d -exec chmod 2775 {} \;"
su - sysop -c "find ./ -type f -exec chmod 775 {} \;"
su - sysop -c "mkdir -p /spider/local"
su - sysop -c "mkdir -p /spider/local_cmd"
su - sysop -c "cp /spider/perl/DXVars.pm.issue /spider/local/DXVars.pm"
su - sysop -c "cp /spider/perl/Listeners.pm /spider/local/Listeners.pm"
su - sysop -c "sed -i '17s/#//' /spider/local/Listeners.pm"
#su - sysop -c "touch /spider/local_data/users.v3j"

#
insert_cluster_call
insert_call
insert_name
insert_email
insert_locator
insert_qth

echo -e "Now create basic user file"
su - sysop -c "/spider/perl/create_sysop.pl"
echo -e " "
echo -e "Installation has been finished."
echo -e "Now login as sysop user.\nStart application and check if everything is ok with follow command /spider/perl/cluster.pl"
}

create_service() {
echo -e " "
echo -e "Now make configuration for systemd dxspider service"
echo -e " "
# systemd script from spider directory to /etc/systemd/system/
#

if [ -f "/usr/lib/systemd/system/dxspider.service" ]; then
    echo "Files dxspider.service exist"
else
        touch /usr/lib/systemd/system/dxspider.service
#
cat >> /usr/lib/systemd/system/dxspider.service <<EOL
[Unit]
Description= Dxspider DXCluster service
After=network.target

[Service]
Type=simple
User=sysop
Group=sysop
ExecStart= /usr/bin/perl -w /spider/perl/cluster.pl
# Comment out line below for logging everything to /var/log/messages
StandardOutput=null
Restart=always

[Install]
WantedBy=multi-user.target
EOL

fi

echo -e " "
}
#
#set up to start on boot
enable_service() {
echo -e "Enable Dxspider Service to start up"
echo -e " "
systemctl enable dxspider
}


main() {
		message
        check_run_user
        echo -e " "
        check_distro
        echo -e " "
        create_user_group
        echo -e " "
		actual_path
		export_user
		stop_dxspider
		update_files
        install_spider
        echo -e " "
        echo -e "Now starting make dxspider configuration"
        echo -e " "
        echo -e "Config files location you can find below /spider/local/DXVars.pm"
        config_app
        echo -e " "
        echo -e "Create systemd dxspider service"
        create_service
        echo -e " "
        enable_service
        echo -e " "
}
# Call Script Main
#
main

exit 0
