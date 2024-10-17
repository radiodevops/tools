# Scripts Description

This repository contains two scripts designed to automate specific tasks on a Linux environment. Below is a description of each script and their respective functionalities.

## Script 1: `setup_environment.sh`

This script is designed to automate the setup of a development environment on a Linux machine. It performs several tasks including installing fonts, tools, and setting system configurations.

### Features:
1. **Font Installation:**
   - Downloads and installs the JetBrains Mono font from the Nerd Fonts repository.
   
2. **Tool Installation:**
   - Installs `k9s`, a Kubernetes CLI tool, to manage clusters.
   - Installs `starship`, a shell prompt, and configures it with a preset configuration.
   
3. **System Configuration:**
   - Sets the hostname of the machine to `dev`.
   - Updates the `.bashrc` file to initialize `starship` upon opening a terminal.

### Usage:
Run the script using the following command:
```
./setup_environment.sh
```
Ensure you have the necessary permissions to execute the script and install the packages.

---

## Script 2: `resize_ebs.sh`

This script is intended for use on AWS EC2 instances to automate the resizing of EBS volumes attached to the instance.

### Features:
1. **Volume Resizing:**
   - Dynamically fetches the instance and volume IDs using AWS metadata.
   - Resizes the EBS volume to a specified size or a default size of 50 GB if not specified.

2. **Disk Operations:**
   - Re-scans the disk to recognize the new size.
   - Grows the partition and resizes the filesystem accordingly.

3. **Support for Multiple Filesystems:**
   - Supports resizing for `xfs`, `ext4`, and `ext3` filesystems.
   - Provides feedback and exits if an unsupported filesystem is detected.

### Usage:
Run the script as root and optionally specify the desired volume size in GB:
```
sudo ./resize_ebs.sh [size_in_gb]
```
Example to resize the volume to 100 GB:
```
sudo ./resize_ebs.sh 100
```

---

## General Information

- Ensure that you have the necessary permissions and configurations (like AWS CLI and credentials configured) to run the scripts without errors.
- It is recommended to backup important data before performing operations such as disk resizing.
- These scripts are intended for Linux environments and might require modifications to work on other operating systems.

For any issues or contributions, please feel free to open an issue or a pull request in this repository.
