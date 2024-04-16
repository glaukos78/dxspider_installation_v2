This script will allow you to update your DXSpider node to the latest build of the MOJO version.

This job is based on the great development of the DXSpider installation script by Yiannis Panagou, SV5FRI.

Before starting the update, a backup of the installation running on your machine will be created.
It is important that you tell the script the path where DXSpider is installed.

Download script:

	wget https://github.com/glaukos78/dxspider_installation_v2/archive/refs/heads/devel.zip -O update_dxspider.zip

Must be run as root user.

Uncompress & change permissions

    unzip update_dxspider.zip

    cd dxspider_installation_v2-devel/

    chmod a+x update_dxspider.sh

Run script and follow the messages.

    ./update_dxspider.sh

Script has been tested on the following Operating Systems (Linux Distributions)

	CentOS Linux 7 (Core)
	CentOS Linux 8 (Core)
	Debian GNU/Linux 9 (stretch)
	Debian GNU/Linux 10 (buster)
	Debian GNU/Linux 11 (bullseye)
	Debian GNU/Linux 12 (bookworm)
	Debian GNU/Linux bookworm/sid
	Fedora Linux 39 (Server Edition)
	Fedora Linux 39 (Workstation Edition)
	Linux Mint 21.1
	Raspbian GNU/Linux 9 (stretch) 
	Raspbian GNU/Linux 10 (buster)
	Raspbian GNU/Linux 11 (bullseye)
	Raspbian GNU/Linux 12 (bookworm)
	Ubuntu 22.04 LTS
	Ubuntu 22.04.1 LTS
	Ubuntu 22.04.2 LTSUbuntu 22.04.3 LTS
	Ubuntu 22.04.4 LTS
	Rocky Linux 8.5 (Green Obsidian)
	
Remember that it is only for updating, for a new installation look at the development of Yiannis Panagou, SV5FRI at:

	https://github.com/glaukos78/dxspider_installation_v2

Those sysops who want to be informed or participate in the evolution, new versions/builds and doubts about DXSpider, can request to subscribe to the official list:

	https://mailman.tobit.co.uk/mailman/listinfo/dxspider-support
	
