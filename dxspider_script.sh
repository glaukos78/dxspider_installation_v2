#!/bin/bash
# Script for Installation and configuration DxSpider Cluster
# Create By Yiannis Panagou, SV5FRI
# http://www.sv5fri.eu
# E-mail:sv5fri@gmail.com
# Version 1.5 - Last Modify 30/04/2020
#
#==============================================
#
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
        echo -e "      Your distribution is ${distroname}"
        echo -e "=============================================================== "
        echo -e " "
        echo -e " "

        read -n 1 -s -r -p "Press any key to continue"

        if [ "${distroname}" == "CentOS Linux 7 (Core)" ]; then
                install_epel_7
                install_package_CentOS_7
                    elif [ "${distroname}" == "Raspbian GNU/Linux 8 (jessie)" ]; then
                                install_package_debian
                    elif [ "${distroname}" == "Raspbian GNU/Linux 9 (stretch)" ]; then
                                install_package_debian
                    elif [ "${distroname}" == "Debian GNU/Linux 9 (stretch)" ]; then
                                install_package_debian
                else
            exit 1
        fi
}

## CentOS 7.x
#
install_epel_7() {
#Install epel repository
## RHEL/CentOS 7 64-Bit ##
# wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -ivh epel-release-latest-7.noarch.rpm
# Update the system
    yum check-update
# Install the additional package repository EPEL
    yum -y install epel-release
}

# Install extra packages for CentOS 7.x
install_package_CentOS_7() {
# Update the system
#yum check-update
# Install extra packages
    yum -y install perl git gcc make perl-TimeDate perl-Time-HiRes perl-Digest-SHA1 perl-Curses perl-Net-Telnet perl-Data-Dumper perl-DB_File perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-Digest-SHA perl-IO-Compress perl-Math-Round
}

## Deban & raspbian
#
install_package_debian() {
# Update the system
    apt-get update
# Install extra packages
    apt-get -y install perl libtimedate-perl libnet-telnet-perl libcurses-perl libdigest-sha-perl libdata-dumper-simple-perl git
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

install_spider() {
# Create symbolic links
ln -s /home/sysop/spider /spider
# Download Application dxspider with git
echo -e "Now starting to download application DxSpider"
echo -e " "
su - sysop -c "git clone git://scm.dxcluster.org/scm/spider"
#
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm EV Mojolicious JSON JSON::XS


echo -e " "
}

config_app(){
# Fix up permissions ( AS THE SYSOP USER )
echo "Fix up permissions"
echo -e " "
echo -e "Please use capital letters"
echo -e " "
#
su - sysop -c "mkdir /spider/local_data"
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

enable_service() {
echo -e " "
echo -e "Now make configuratio for systemd service"
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

#
#set up to start on boot
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
        echo -e "Now starting make dxspider configuration"
        echo -e "Config files location you can find below /spider/local/DXVars.pm"
        config_app
        echo -e " "
        enable_service
        echo -e " "
}
# Call Script Main
#
main

exit 0
