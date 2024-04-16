#!/bin/bash

#
# Script for UPDATE and DXSpider Cluster configuration
# Upgrade from Master or Mojo to the latest Mojo version
#
# Create By Kin, EA3CV and based on the code of Yiannis Panagou, SV5FRI
#
# E-mail: ea3cv@cronux.net
# Version 0.4
# Date 20231116
#


backup()
{
        is_spider
        is_service
	is_backup
        make_config
	stop_spider

        if [ ${BACKUP} = "true" ]; then
                echo "A backup directory already exists."
                echo "Do you want to delete it? [Y/N] "
                chr="\""
                read YESNO
                if [ ${YESNO} = "N" ]; then
			stop_spider
			mv /home/spider.backup/config.backup.old /home/spider.backup/config.backup
                        echo "Using the current Backup."
		elif [ ${YESNO} = "Y" ]; then
		        echo " "
		        echo "Backup begins ..."
		        stop_spider
		        mkdir /home/spider.backup
		        mv ${OLD_SERVICE_PATH} /home/spider.backup/dxspider.service
		        cp -r ${DXSPATH} /home/spider.backup
		else
			echo "Bye!"
			exit 1
                fi
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
			elif [ "${distroname}" == "Raspbian GNU/Linux 12 (bookworm)" ]; then
                                install_package_debian
                        elif [ "${distroname}" == "Debian GNU/Linux 11 (bullseye)" ]; then
                                install_package_debian
			elif [ "${distroname}" == "Debian GNU/Linux 12 (bookworm)" ]; then
                                install_package_debian
			elif [ "${distroname}" == "Ubuntu 22.04 LTS" ]; then
    				install_package_debian
			elif [ "${distroname}" == "Ubuntu 22.04.1 LTS" ]; then
      				install_package_debian
			elif [ "${distroname}" == "Ubuntu 22.04.2 LTS" ]; then
      				install_package_debian
	  		elif [ "${distroname}" == "Ubuntu 22.04.3 LTS" ]; then
      				install_package_debian
	  		elif [ "${distroname}" == "Ubuntu 22.04.4 LTS" ]; then
      				install_package_debian
			elif [ "${distroname}" == "Fedora Linux 39 (Server Edition)" ]; then
      				install_epel_8
      				install_package_CentOS_8
			elif [ "${distroname}" == "Fedora Linux 39 (Workstation Edition)" ]; then
      				install_epel_8
      				install_package_CentOS_8
			elif [ "${distroname}" == "Debian GNU/Linux bookworm/sid" ]; then
                                install_package_debian
			elif [ "${distroname}" == "Linux Mint 21.1" ]; then
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

# Check the script is being run by root user
check_run_user()
{
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run as root" 1>&2
	exit 1
fi
}

config_app()
{
	# Fix up permissions ( AS THE SYSOP USER )
	echo "Fix up permissions"
	echo -e " "
	echo -e "Please use capital letters"
	echo -e " "

        cd ${DXSPATH}

	su - $OWNER -c "cd ${DXSPATH}"
	su - $OWNER -c "cd ${DXSPATH} ; git reset --hard"
	su - $OWNER -c "cd ${DXSPATH} ; git pull"
	su - $OWNER -c "cd ${DXSPATH} ; git checkout --track -b mojo origin/mojo"
	ln -s ${DXSPATH}/perl/console.pl /usr/local/bin/dx
	ln -s ${DXSPATH}/perl/*dbg /usr/local/bin

	chown -R $OWNER.$GROUP spider
	find ./ -type d -exec chmod 2775 {} \;
	find ./ -type f -exec chmod 775 {} \;
	su - $OWNER -c "mkdir -p ${DXSPATH}/local"
	su - $OWNER -c "mkdir -p ${DXSPATH}/cmd_import"
	su - $OWNER -c "mkdir -p ${DXSPATH}/local_cmd"
	su - $OWNER -c "cp ${DXSPATH}/perl/DXVars.pm.issue ${DXSPATH}/local/DXVars.pm"
	#su - $OWNER -c "touch /spider/local_data/users.v3j"

	insert_cluster_call
	insert_call
	insert_name
	insert_email
	insert_locator
	insert_qth

	echo -e "Now create basic user file"
	su - $OWNER -c "/spider/perl/create_sysop.pl"
	echo -e " "
	echo -e "Installation has been finished."
	echo -e "Now login as sysop user.\nStart application and check if everything is ok with follow command /spider/perl/cluster.pl"
}

create_service()
{
	echo -e " "
	echo -e "Now make configuration for systemd dxspider service"
	echo -e " "
	# systemd script from spider directory to /etc/systemd/system/
	#

	if [ -f "/etc/systemd/system/dxspider.service" ]; then
		echo "Files dxspider.service exist"
	else
	        touch /etc/systemd/system/dxspider.service
	#
	cat >> /etc/systemd/system/dxspider.service <<EOL
[Unit]
Description= Dxspider DXCluster service
After=network.target

[Service]
Type=simple
User=$OWNER
Group=$GROUP
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

enable_service()
{
	echo -e "Enable Dxspider Service to start up"
	echo -e " "
	systemctl enable dxspider
	systemctl start dxspider
}

## CentOS 7.x
#
install_epel_7()
{
	#Install epel repository
	## RHEL/CentOS 7 64-Bit ##
	# Update the system
	yum check-update ; yum -y update
	# Install the additional package repository EPEL
	yum -y install epel-release
}

# Install extra packages for CentOS 7.x
install_package_CentOS_7()
{
	echo -e "Starting Installation Dxspider Cluster"
	echo -e " "
	# Update the system
	yum check-update ; yum -y update
	# Install extra packages
	yum -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Digest-SHA1 perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-Digest-SHA perl-IO-Compress curl libnet-cidr-lite-perl
	cpanm install Curses
}

## CentOS 8.x
#
install_epel_8()
{
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
install_package_CentOS_8()
{
	# Update the system
	dnf check-update ; dnf -y update
	# Install extra packages
	dnf -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-IO-Compress perl-Digest-SHA perl-Net-CIDR-Lite curl libnet-cidr-lite-perl
}

## Debian & raspbian
#
install_package_debian()
{
	echo -e "Starting Installation Dxspider Cluster"
	echo -e " "
	# Update the system
	apt-get update ; apt-get -y upgrade
	# Install extra packages
	apt-get -y install perl libtimedate-perl libnet-telnet-perl libcurses-perl libdigest-sha-perl libdata-dumper-simple-perl git libjson-perl libmojolicious-perl  libdata-structure-util-perl libmath-round-perl libev-perl libjson-xs-perl build-essential procps libnet-cidr-lite-perl curl
}

# Enter CallSign for cluster
insert_cluster_call()
{
	echo -n "Please enter CallSign for DxCluster: "
	chr="\""
	read DXCALL
	echo ${DXCALL}
	su - $OWNER -c "sed -i 's/mycall =.*/mycall = ${chr}${DXCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your CallSign
insert_call()
{
	echo -n "Please enter your CallSign: "
	chr="\""
	read SELFCALL
	echo ${SELFCALL}
	su - $OWNER -c "sed -i 's/myalias =.*/myalias = ${chr}${SELFCALL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your Name
insert_name()
{
	echo -n "Please enter your Name: "
	chr="\""
	read MYNAME
	echo ${MYNAME}
	su - $OWNER -c "sed -i 's/myname =.*/myname = ${chr}${MYNAME}${chr};/' /spider/local/DXVars.pm"
}

# Enter your E-mail
insert_email()
{
	echo -n "Please enter your E-mail Address(syntax like your\@email.com): "
	chr="\""
	read EMAIL
	echo ${EMAIL}
	su - $OWNER -c "sed -i 's/myemail =.*/myemail = ${chr}${EMAIL}${chr};/' /spider/local/DXVars.pm"
}

# Enter your mylocator
insert_locator()
{
	echo -n "Please enter your Locator(Use Capital Letter): "
	chr="\""
	read MYLOCATOR
	echo ${MYLOCATOR}
	su - $OWNER -c "sed -i 's/mylocator =.*/mylocator = ${chr}${MYLOCATOR}${chr};/' /spider/local/DXVars.pm"
}

# Enter your myqth
insert_qth()
{
	echo -n "Please enter your QTH(use comma without space): "
	chr="\""
	read MYQTH
	echo ${MYQTH}
	su - $OWNER -c "sed -i 's/myqth =.*/myqth = ${chr}${MYQTH}${chr};/' /spider/local/DXVars.pm"

	echo -e " "
	echo -e "================================================================="
	echo -e "                         ATTENTION"
	echo -e " "
	echo -e "It is recommended that if you want to keep the user database,"
	echo -e "answer "N" when asked:"
	echo -e " "
	echo -e "Do you wish to destroy your user database (THINK!!!) [y/N]: N"
	echo -e " "
	echo -e "As the Node data will be requested again, the following question"
	echo -e "must be answered with a "Y":"
	echo -e " "
	echo -e "Do you wish to reset your cluster and sysop information? [y/N]: Y"
	echo -e " "
	echo -e "================================================================="
	echo -e " "
}

is_backup()
{
        if [ ! -z "$(ls -A /home/spider.backup)" ]; then
                BACKUP="true"
                echo "Backup exits and not is empty."
        else
                BACKUP="false"
                echo "Backup not exits."
        fi
}

is_service()
{
        STATUS=$(systemctl is-active dxspider)

        if [ $STATUS = "active" ] || [ $STATUS = "inactive" ]; then
		OLD_TYPE="service"
#               OLD_SERVICE_PATH=$(find /etc -name dxspider.service)
		OLD_SERVICE_PATH="/etc/systemd/system/dxspider.service"
                echo "DXSpider is using systemctl."
                echo "DXSpider is running."
        else
                PID=$(pgrep -f cron | cut -d $'\n' -f1)
		OLD_TYPE="pid"
                echo "DXSpider has the PID $PID"

        fi
}

is_spider()
{
	if [ -f "$DXSPATH/perl/cluster.pl" ]; then
		echo "Getting owner and group ..."
		OWNER=$(stat -c '%U' $DXSPATH/perl/cluster.pl)
		GROUP=$(stat -c '%G' $DXSPATH/perl/cluster.pl)
	else
                echo "DXSpider is not installed where indicated."
		echo "Try again."
                echo "Bye!"
		exit 0
	fi
}

make_backup()
{
	if [ $BACKUP = "true" ]; then
                echo "A backup directory already exists."
		echo "Do you want to delete it? [Y/N] "
		chr="\""
		read YESNO
		if [ $YESNO = "Y" ]; then
                	echo " "
                	echo "Backup begins ..."
			rm -rf /home/spider.backup
			cp -r ${DXSPATH} /home/spider.backup

		else
			echo "Using the current Backup."
		fi
        else
                PID=$(pgrep -f cron | cut -d $'\n' -f1)
                echo "DXSpider has the PID $PID"
        fi



}

make_config()
{
        if [ -f "/home/spider.backup/config.backup" ]; then
		mv /home/spider.backup/config.backup /home/spider.backup/config.backup.old
	else
		mkdir /home/spider.backup
		touch /home/spider.backup/config.backup
		cat >> /home/spider.backup/config.backup <<EOL
owner=$OWNER
group=$GROUP
old_type=$OLD_TYPE
old_dxs_path=$DXSPATH
old_service_path=$OLD_SERVICE_PATH
EOL

	fi
}

read_config()
{
	# File /home/spider.backup/config.backup
	# owner=
	# group=
        # old_type=service|pid
        # path_old_spider=/../..
        # path_old_service=/../..

	while IFS== read -r type value
	do
		if [ $type = "owner" ]; then
                        OWNER=$value
                        echo $OWNER
                elif [ $type = "group" ]; then
                        GROUP=$value
                        echo $GROUP
                elif [ $type = "old_type" ]; then
                        OLD_TYPE=$value
                        echo $OLD_TYPE
                elif [ $type = "old_dxs_path" ]; then
                        OLD_DXS_PATH=$value
                        echo "Restoring  backup to $OLD_DXS_PATH"
                elif [ $type = "old_service_path" ]; then
                        OLD_SERVICE_PATH=$value
                        echo $OLD_SERVICE_PATH
                fi

	done < /home/spider.backup/config.backup
}

run_restore()
{
	if [ ${BACKUP} = "true" ]; then
		stop_spider
                systemctl disable dxspider
		rm -rf ${DXSPATH}
		mkdir ${OLD_DXS_PATH}
		cp -r /home/spider.backup/spider ${OLD_DXS_PATH}/../
                cd ${OLD_DXS_PATH}
                chown -R $OWNER.$GROUP ${OLD_DXS_PATH}
                find ./ -type d -exec chmod 2775 {} \;
                find ./ -type f -exec chmod 775 {} \;

		cp /home/spider.backup/dxspider.service $OLD_SERVICE_PATH
		systemctl enable dxspider
		systemctl start dxspider
		echo "Backup restored."
		echo "DXSpider running."
		echo "Bye!"

	else
		echo "Error in /home/spider.backup/config.backup"
		echo "Bye."
	fi
}

stop_spider()
{
        if [ "${PID}" ]; then
                kill -9 ${PID}
        else
                # Is service
                systemctl stop dxspider
        fi
}

update_spider()
{
	# Update to MOJO version
	# Create symbolic links
	cd ${DXSPATH}
	ln -s ${DXSPATH} /spider

	# Download Application dxspider with git
	echo -e "Now starting to download application DxSpider"
	echo -e " "
	su - $OWNER -c "git clone git://scm.dxcluster.org/scm/spider"
	#
	curl -L https://cpanmin.us | perl - App::cpanminus
	cpanm EV Mojolicious JSON JSON::XS Data::Structure::Util Math::Round

	echo -e " "
}

welcome()
{
        clear
        echo -e " "
        echo -e "==============================================================="
        echo -e " "
        echo -e "This script update will make a Backup of the current DXSpider"
        echo -e "software in the /home/spider.backup directory"
        echo -e "Users, DB and configuration files will be maintained."
        echo -e " "
        echo -e "Only OS versions that have been verified will be supported."
        echo -e " "
        echo -e "==============================================================="
        echo -e " "
        read -n 1 -s -r -p $'Press any key to continue ...'
        echo -e " "
        echo -e "Indicates path where DXSpider is installed."
        echo -n "For example: /home/spider or /home/sysop/spider or ... : "
        chr="\""
        read DXSPATH
        echo -e " "
        echo -e "==============================================================="
        echo -e "To upgrade your DXSpider, press [U]"
        echo -e "To restore the backup, press [R]"
        echo -e "==============================================================="
        echo -e " "
        echo -n "Please enter [U]pdate, [R]estore o [Q]uit: "
        chr="\""
        read OPTION

        if [ "${OPTION}" == "U" ]; then
                echo -e " "
                echo -e "==============================================================="
                echo -e "                     Updating DXSpider..."
                echo -e "==============================================================="
                echo -e " "

                backup
		check_distro
		mkdir ${DXSPATH}/local_data
		cp ${DXSPATH}/data/* ${DXSPATH}/local_data/.
		update_spider
		config_app
		create_service
		enable_service

                echo -e " "
                echo -e "==============================================================="
                echo -e "                      DXSpider Updated"
                echo -e "==============================================================="
                echo -e " "

        elif [ "${OPTION}" == "R" ]; then
                echo -e " "
                echo -e "==============================================================="
                echo -e "                     Restore DXSpider..."
                echo -e "==============================================================="
                echo -e " "

		is_backup
		read_config
		run_restore

        elif [ "${OPTION}" == "Q" ]; then
                echo -e " "
                echo -e "==============================================================="
                echo -e "                     Bye. See you next time"
                echo -e "==============================================================="
                echo -e " "
        fi
}

main()
{
	check_run_user
	welcome
}

main

exit 0
