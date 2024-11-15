Key Features of the DXSpider Installation Script

This script is designed to install and configure a DXSpider Cluster using the MOJO repository efficiently and in just a few minutes. Here are its main advantages:

Installation Steps for DXSpider

Follow the steps below to install DXSpider using the provided script. Ensure you are logged in as the root user or have appropriate privileges to run these commands:

1. Download the Installation Script

Use wget to download the script from the GitHub repository:

wget https://github.com/glaukos78/dxspider_installation_v2/archive/refs/heads/main.zip -O dxspider_installation.zip

2. Verify Root Privileges

Ensure you are running as the root user before proceeding. You can check this with:

whoami

If the output is not root, switch to the root user or use sudo where necessary.
3. Uncompress and Set Permissions

Unzip the downloaded file and navigate to the extracted directory. Then, set the appropriate permissions for the installation script:

unzip dxspider_installation.zip
cd dxspider_installation_v2-main/
chmod a+x install_dxspider.sh

4. Run the Installation Script

Execute the installation script and follow the on-screen prompts to complete the setup:

./install_dxspider.sh

By following these steps, DXSpider will be installed on your system. If you encounter any errors, ensure all dependencies are met and permissions are correctly set.

Supported Operating Systems for DXSpider Installation Script

The installation script has been tested and verified to work on the following Linux distributions:

CentOS

    CentOS Linux 8 (Core)

Rocky Linux

    Rocky Linux 8.5 (Green Obsidian)
    Rocky Linux 9.4 (Blue Onyx)

AlmaLinux

    AlmaLinux 9.4 (Seafoam Ocelot)

Raspbian (Debian-based)

    Raspbian GNU/Linux 9 (stretch)
    Raspbian GNU/Linux 10 (buster)
    Raspbian GNU/Linux 11 (bullseye)
    Raspbian GNU/Linux 12 (bookworm)

Debian

    Debian GNU/Linux 9 (stretch)
    Debian GNU/Linux 10 (buster)
    Debian GNU/Linux 11 (bullseye)
    Debian GNU/Linux 12 (bookworm)
    Debian GNU/Linux bookworm/sid

Ubuntu

    Ubuntu 22.04 LTS
    Ubuntu 22.04.1 LTS
    Ubuntu 22.04.2 LTS
    Ubuntu 22.04.3 LTS
    Ubuntu 22.04.4 LTS
    Ubuntu 24.04 LTS
    Ubuntu 24.04.1 LTS

Fedora

    Fedora Linux 40 (Server Edition)
    Fedora Linux 40 (Workstation Edition)
    Fedora Linux 41 (Server Edition)
    Fedora Linux 41 (Workstation Edition)

Linux Mint

    Linux Mint 21.1

Ensure you are using one of the above operating systems for compatibility with the script. If your distribution is not listed, the script might still work, but functionality has not been officially confirmed.
