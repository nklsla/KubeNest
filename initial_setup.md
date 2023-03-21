
# Setup All Nodes
The following has to be done on all nodes.\
Most of these steps and instructions have I shamelessly taken from [Kubernets](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) and various guides I've found. 

## Enable kernel modules
```
# Download prequsites
sudo apt install curl

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
This is necessary for the `kubelet`service to work properly and will allow better performance (i.e. if your machine has enough of RAM).

- Open the file `/etc/fstab`
- Comment out the "swap" line

then run following to disable swap and confirm.
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

## Set up UFW and open ports
see: https://adamtheautomator.com/ufw-firewall/ \
see: https://adamtheautomator.com/cri-o/ 

## Install the CRI
I will use CRI-O to hot things up.
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

Since I'm suing `crun`, some modifications has to be done to the cri-o config. \
Edit `/etc/crio/crio.conf` and add following under `[crio.runtime]`:
```
default_runtime = "crun"
# MIGHT NOT NEED THIS?
#[crio.runtime.runtimes.crun]
#allowed_annotations = [
#    "io.containers.trace-syscall",
#]
```

and make sure these paths are set as below under the `[crio.network]`-section:
```
[crio.network]

# The default CNI network name to be selected. If not set or "", then
# CRI-O will pick-up the first one found in network_dir.
# cni_default_network = ""

# Path to the directory where CNI configuration files are located.
 network_dir = "/etc/cni/net.d/"

# Paths to directories where CNI plugin binaries are located.
 plugin_dirs = [
 	"/usr/lib/cni/",
 ]

```

add this to the end of the `/etc/crio/crio.conf.d/01-crio-runc.conf`:
```
[crio.runtime.runtimes.crun]
runtime_path = "/usr/bin/crun"
runtime_type = "oci"
runtime_root = "/run/crun"
```

Now restart and enable `crio` to start on boot: 
```
systemctl restart crio
systemctl enable crio
systemctl status crio
```

## Install Kubernetes
Now it's time to install kubernetes!

```
# Adding Kubernetes repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Adding GPG key for Kubernetes repository
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Update apt
sudo apt update

# Installing kubernetes and tools
sudo apt install kubelet=1.26.2-00 kubeadm=1.26.2-00 kubectl=1.26.2-00
```

Optional:
```
# Lock packages to avoid potential problems with updates
sudo apt-mark hold kubelet kubeadm kubectl
```

## Install worker node

