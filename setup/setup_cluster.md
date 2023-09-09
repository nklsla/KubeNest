
# Setup Kubernetes
The following have to be done on all nodes.\
Most of these steps and instructions have I shamelessly taken from [Kubernets.io](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/), [AdamTheAutomator](https://adamtheautomator.com/cri-o/) and other various other guides I've found. 
I've rewritten it here as a condensed version for this specific setup.
<!--toc-->

- [Prerequisite](#prerequisite)
  * [SSH](#ssh)
  * [Packages](#packages)
- [Enable kernel modules](#enable-kernel-modules)
- [Disable swap](#disable-swap)
  * [Manual file changes](#manual-file-changes)
  * [Turn off for current session](#turn-off-for-current-session)
- [Install the Container Runtime Interface](#install-the-container-runtime-interface)
  * [Changes in CRI-O config](#changes-in-cri-o-config)
- [Install Kubernetes](#install-kubernetes)
- [Firewall setup](#firewall-setup)

## Prerequisite
### SSH
First thing before installing anything; setup communication over SSH.
[Setup SSH](setup_ssh.md): Follow *"Setup SSH service"* and _"Security changes in SSHD config"_

Make sure the machine gets logged in automatically if rebooted remotely.
- In Ubuntu desktop 22.04
  - Settings > Users: Enable "Automatic Login"
For laptops it's recommended to [disable hibernation/sleep](setup_extra.md#ubuntu-server-specific)


### Packages
Install following packages on all nodes
```
sudo apt update

# For installing kubernets
sudo apt install curl ca-certificates apt-transport-https

# For mounting NFS-server
sudo apt install nfs-common 
```



## Enable kernel modules
```
# Enabling kernel modules (overlay and br_netfilter)
sudo modprobe overlay
sudo modprobe br_netfilter

# Automatically load kernel modules via the config file
cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

# Setting up kernel parameters via config file
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Applying new kernel parameters
sudo sysctl --system
```
## Disable swap
This is necessary for the `kubelet`service to work properly and will allow better performance (i.e. if your machine has enough of RAM). Swap is used by the operating system to create temporary virtual RAM-memory using the hard drives space (i.e. SSD) when the RAMs physical memory is fully utilized.

### Manual file changes
Disabling swap manually like below will make sure it is turned off when the system restarts.
- Open the file `/etc/fstab`
- Comment out the "swapfile" line

Example of `/etc/fstab`:
 
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme0n1p6 during installation
UUID=1280b09c-bdbb-4dc9-b93f-34d6323a97da /               ext4    errors=remount-ro 0       1
# /boot/efi was on /dev/nvme0n1p1 during installation
UUID=184F-388A  /boot/efi       vfat    umask=0077      0       1
#/swapfile                                 none            swap    sw              0       0
```

### Turn off for current session
Run following to disable swap for the current session.

```
# Disable swap
sudo swapoff -a

# Checking swap via /procs/swaps
# Should return empty list/table
cat /proc/swaps

# Checking swap via command free -m
# Should show that swap = 0
sudo free -m
```

## Install the Container Runtime Interface
This setup/project uses __CRI-O__ as __CRI__ since it is optimized for Kubernetes. 
```
# Creating environment variable $OS and $VERSION
export OS=xUbuntu_22.04
export VERSION=1.26

# Adding CRI-O repository for Ubuntu systems
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee -a /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee -a /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

# Creating directory /usr/share/keyrings
mkdir -p /usr/share/keyrings

# Downloading GPG key for CRI-O repository
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

# Update and refresh package index
sudo apt update

# Install CRI-O and crun
sudo apt install cri-o crun
```

This setup will be using `crun` due to it being lightweight and better performance than `runc`, but that means some modifications have to be done to the cri-o config.

### Changes in CRI-O config
Open `/etc/crio/crio.conf` and add/edit following under `[crio.runtime]`:
```
default_runtime = "crun"

# Not sure if the settings below is needed..
#[crio.runtime.runtimes.crun]
#allowed_annotations = [
#    "io.containers.trace-syscall",
#]
```

make sure these paths are set as below under the `[crio.network]`-section:
```
[crio.network]

# The default CNI network name to be selected. If not set or "", then
# CRI-O will pick-up the first one found in network_dir.
# cni_default_network = ""

# Path to the directory where CNI configuration files are located.
 network_dir = "/etc/cni/net.d/"

# Paths to directories where CNI plugin binaries are located.
# This part seems to cause "NetworkPluginNotReady.. Keep it commented out.
# plugin_dirs = [
# 	"/usr/lib/cni/",
# ]

```


Open `/etc/crio/crio.conf.d/01-crio-runc.conf` and add at the end of file:
```
[crio.runtime.runtimes.crun]
runtime_path = "/usr/bin/crun"
runtime_type = "oci"
runtime_root = "/run/crun"
```

Now restart and enable CRI-O to start on boot: 
```
systemctl restart crio
systemctl enable crio
systemctl status crio
```

## Install Kubernetes
Now it's time to install kubernetes!

Version `1.25.10-00` is used because of KubeFlow requirements.
Following [step 1-3 in this guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management)
``` 
# Download Google Cloud public signing key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Adding Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt
sudo apt update

# Installing kubernetes and tools
sudo apt install kubelet=1.25.10-00 kubeadm=1.25.10-00 kubectl=1.25.10-00

# Lock packages for version control
sudo apt-mark hold kubelet kubeadm kubectl
```

## Firewall setup
[See here](setup_firewall.md)
