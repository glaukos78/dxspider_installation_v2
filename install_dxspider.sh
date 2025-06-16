#!/bin/bash
# Script for deployment and configuration DxSpider Cluster
# Create By Yiannis Panagou, SV5FRI
# https://www.sv5fri.eu
# E-mail:sv5fri@gmail.com
# Version 1.26 - Last Modify 16/06/2025
#
#Change Log
#=====================================================================================================
# 08/02/2022 - 1.8 - Update script to support Debian 11 (bullseye) & Raspbian GNU/Linux 11 (bullseye)
# 08/02/2022 - 1.9 - Support Mojo installation
# 15/05/2022 - 1.10 - Fix bug installation package into RHEL8/CentOS8/Rocky8
# 18/05/2022 - 1.11 - Fix installation added curl package for all distributions
# 18/05/2022 - 1.12 - Minor fix packages to Debian / Raspbian distributions
# 02/01/2023 - 1.13 - Added Ubuntu 22.04 LTS, Ubuntu 22.04.1 LTS, Fedora Linux 37 (Server Edition),
#                     Fedora Linux 37 (Workstation Edition)
# 23/01/2023 - 1.14 - Added support Debian GNU/Linux bookworm/sid (Thanks HG8LXL Laci)
# 23/01/2023 - 1.15 - Added support Ubuntu 22.04.2 LTS (Thanks F5LEN )
# 21/03/2023 - 1.16 - Added support Linux Mint 21.1 (Thanks G7VJA)
# 22/08/2023 - 1.17 - Added support Ubuntu 22.04.3 LTS (Thanks IW2DRM )
# 13/10/2023 - 1.18 - Added support Raspbian GNU/Linux 12 (bookworm) (Thanks G6HNU )
# 03/01/2024 - 1.19 - Added support Debian GNU/Linux 12 (bookworm) (Thanks G7VJA )
# 09/03/2024 - 1.20 - Added support Ubuntu 22.04.4 LTS (Thanks K1AX ) & Added support Fedora Linux 39 (Server Edition),
#                     Fedora Linux 39 (Workstation Edition) & Remove suppo Fedora Linux 37 (Server Edition),
#                     Fedora Linux 37 (Workstation Edition)
# 29/07/2024 - 1.21 - Added support AlmaLinux 9.4 & Added support Fedora Linux 40 (Server Edition),
#                     Fedora Linux 40 (Workstation Edition) & Remove CenOS 7
# 01/11/2024 - 1.22 - Added support Ubuntu 24.04.1 LTS & Make fix (apt) package manager for Debian and Ubuntu (Thanks VK4SE)
# 11/11/2024 - 1.23 - Add Ubundu 24.04 LTS
# 14/11/2024 - 1.24 - Make changes to function Check ditribution and version. Make new way to read distrobution and version
#                     Added support Fedora Linux 41 (Server Edition), Fedora Linux 41 (Workstation Edition).
#                     Add libraries libdbd-mysql-perl libdbd-mariadb-perl - Maybe also include installation of libdbd-mysql-perl #6
#                     Remove Fedora Linux 39 (Server Edition), Fedora Linux 39 (Workstation Edition)
# 30/03/2025 - 1.25 - Added Ubundu 24.04.2 LTS and removed Debian GNU/Linux bookworm/sid
# 16/06/2025 - 1.26 - Added Ubundu 25.04
#=================================================================================================================================
#
#
# Check the script is being run by root user)
check_run_user() {
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
}

# Load distro actions from external file
load_distro_actions() {
    declare -gA distro_actions  # Declare a global associative array

    # Check if config file exists
    if [ ! -f "distro_actions.conf" ]; then
        echo "Configuration file 'distro_actions.conf' not found!"
        exit 1
    fi

    # Load each line from config file
    while IFS=, read -r name actions; do
        # Trim any leading/trailing whitespace from name and actions
        name=$(echo "$name" | xargs)
        actions=$(echo "$actions" | xargs)

        # Store in associative array
        distro_actions["$name"]="$actions"
    done < distro_actions.conf
}

# Function to check OS distribution and version
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

    # Load actions from config file
    load_distro_actions

    # Check if distribution is supported
    if [[ -n "${distro_actions[$distroname]}" ]]; then
        echo -e "\n==============================================================="
        echo -e "      Your OS distribution is ${distroname}"
        echo -e "===============================================================\n"
        read -n 1 -s -r -p $'Press any key to continue...\n\n'
        
        # Execute the mapped actions for the distribution
        eval "${distro_actions[$distroname]}"
    else
        echo -e "\n==============================================================="
        echo -e "      Your OS distribution ${distroname} is not supported"
        echo -e "===============================================================\n"
        exit 1
    fi
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
        dnf -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-IO-Compress perl-Digest-SHA perl-Net-CIDR-Lite curl perl-DBD-MySQL perl-DBD-MariaDB
}


## Rocky 9.x
#
install_epel_9() {
#Install epel repository
   echo -e "Starting Installation Dxspider Cluster"
   echo -e " "
## RHEL/CentOS 9 64-Bit ##
# Update the system
    dnf makecache --refresh
    dnf check-update ; dnf -y update
# Install the additional package repository EPEL
    dnf -y install epel-release
}

# Install extra packages for Rocky 9.x
install_package_Rocky_9() {
# Update the system
        dnf check-update ; dnf -y update
# Install extra packages
        dnf -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-IO-Compress perl-Digest-SHA perl-Net-CIDR-Lite curl perl-DBD-MySQL perl-DBD-MariaDB
}

## Debian & Ubuntu & Raspbian
#
install_package_debian() {
    echo -e "Starting Installation Dxspider Cluster"
        echo -e " "
# Update the system
    apt update ; apt -y upgrade
# Install extra packages
    apt -y install perl libtimedate-perl libnet-telnet-perl libcurses-perl libdigest-sha-perl libdata-dumper-simple-perl git libjson-perl libmojolicious-perl  libdata-structure-util-perl libmath-round-perl libev-perl libjson-xs-perl build-essential procps libnet-cidr-lite-perl curl libdbd-mysql-perl
}


# Create User and group - Create Directory and Symbolic Link
check_if_exist_user() {
grep -E "^sysop:" /etc/passwd;
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
grep -E "^spider" /etc/group;
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

install_spider() {
# Create symbolic links
ln -s /home/sysop/spider /spider
# Download Application dxspider with git
echo -e "Now starting to download application DxSpider"
echo -e " "
su - sysop -c "git clone git://scm.dxcluster.org/scm/spider"
#
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm EV Mojolicious JSON JSON::XS Data::Structure::Util Math::Round --force


echo -e " "
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
su - sysop -c "chown -R sysop:spider spider"
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
        check_run_user
        echo -e " "
        check_distro
        echo -e " "
        create_user_group
        echo -e " "
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
