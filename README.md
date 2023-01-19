This script will allow you to update your DXSpider node to the latest build of the MOJO version.

Before starting the update, a backup of the installation running on your machine will be created.
It is important that you tell the script the path where DXSpider is installed.

Download script:

	wget https://github.com/glaukos78/dxspider_installation_v2/archive/refs/heads/devel.zip -O dxspider_update.zip

Must be run as root user.

Uncompress & change permissions

    unzip dxspider_update.zip

    cd dxspider_installation_v2-devel/

    chmod a+x update_dxspider.sh

Run script and follow the messages.

    ./update_dxspider.sh

Script has been tested on the following Operating Systems (Linux Distributions)

    CentOS 7
    CentOS 8
    Rocky 8
    Raspbian 9 (stretch)
    Raspbian 10 (buster)
    Raspbian 11 (bullseye)
    Debian GNU/Linux 9 (stretch)
    Debian GNU/Linux 10 (buster)
    Debian GNU/Linux 11 (bullseye)
    Ubuntu 22.04 LTS
    Ubuntu 22.04.1 LTS
    Fedora Linux 37 (Server Edition)
    Fedora Linux 37 (Workstation Edition)
	
Remember that it is only for updating, for a new installation look at the development of Yiannis Panagou, SV5FRI at:

	https://github.com/glaukos78/dxspider_installation_v2

Those sysops who want to be informed or participate in the evolution, new versions/builds and doubts about DXSpider, can request to subscribe to the official list:

	https://mailman.tobit.co.uk/mailman/listinfo/dxspider-support
	
