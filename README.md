# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


__TODO: UPDATE THE TOC__\
__TODO: Apply secure connections, Firewall,TLS etc.__\
__TODO: Security for registry, login should be more sophisticated__\
__TODO: Install nfs-commmon on all nodes for nfs-persistentvolume `sudo apt install nfs-common__ \

## My setup
### Tools
- Ubuntu server 22.04\
- Manjaro 22.04\
- Kubectl\
- Kubeadm\
- CRI-O (CRI)\
- crun \
- Flannel (CNI)\
- Docker as local registry)\
- Neovim

### Master Node (Control-plane)
OS: Ubuntu server 22.04.2\
CPU: 64-bit Intel i3-2310M CPU @ 2.10GHz, 4 cores \
GPU: - \
RAM: 4 GB \
DISK: 700GB, HDD (yes..)


### Worker Node 1
OS: Ubuntu server 22.04.2 \
CPU: 64-bit Intel i7-6700HQ CPU @ 2.60GHz, 8 cores \
GPU: NVIDIA GeForce GTX 960M, 2048 MB GDDR5, 640 CUDA cores (5.0) \
RAM: 8 GB \
DISK: 240 GB, SSD


### Worker Node 2 (temporary)
OS: Ubuntu 22.04 \
CPU: \
GPU: \
RAM: \
DISK:


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
Now it's time to install

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


### Mark manual work
https://adamtheautomator.com/cri-o/
run setup-script.sh

## Install worker node
turn off sleep when lid closes
turn off screen when lid closes

## Start up
-initiazion script
-SSH join commands to nodes \
-Run join commands from master \
`kubectl taint nodes <name> node-role.kubernetes.io/role-` \
`kubectl taint nodes eva node-role.kubernetes.io/control-plane-`


# Setup Container Registry
This will setup a local container registry on the master node and make it available for all nodes in the kubernetes cluster. The workflow is to develop images using docker and push them to the registry. Then apply a kubernetes-job/deployment which will tell a node to pull the images from the registry.

Will probably use docker as registry as this is what I use for development of containers.\

## Install docker
```sudo apt install docker```

Add user to group before you do any docker commands

```
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```
If you did docker commands using `sudo` before adding user to docker group and get:
```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/images/json": dial unix /var/run/docker.sock: connect: permission denied
```
Try
```
sudo chown root:docker /var/run/docker.sock
# If above doesnt work:
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```
## Authentication for registry
Set up a TLS certificate using __openssl__ and authenticate users with __htpasswd__.
I had some issues when letting the command auto create files so I had to pre allocate them.
```
sudo mkdir /srv/registry
cd /srv/registry
sudo mkdir cert auth
sudo touch cert/tls.crt cert/tls.key

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout cert/tls.key -out cert/tls.crt -subj "/CN=docker-registry" -addext "subjectAltName = DNS:docker-registry"
```

Add user authentication to be able to use the docker registry.\
  __TODO: Change user and password __
```
sudo touch auth/htpasswd
sudo chmod 777 auth/htpasswd
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn myuser mypasswd > auth/htpasswd
sudo chmod 644 auth/htpasswd
```
Distribute the certificate, this has to be done on all nodes!
```
  sudo echo {“insecure-registries” : [“docker-registry:5000”]} > /etc/docker/daemon.json
  systemctl restart snap.docker.dockerd.service
  # systemctl restart docker 
  sudo cp /srv/regitry/cert/tls.crt /etc/docker/certs.d/docker-registry:5000/ca.crt
```
Then you need to log in once to get the basic authentication\
  local port for the host machine or inside the cluster\
  nodePort for machines outside the cluster
```
  docker login docker-registry:<local port or nodePort>
  # Username: myuser
  # Password: mypasswd
  ```
Create secretes in kubernetes to mount the certificates and password.
```
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd
```
## Expose the registry
Once the service is up and running. This will make sure nodes within the cluster can access it and machine outside should be able to access as well, to push in new code.
### Expose within the cluster
From `service` manifest: Use port fomr the `port` or `targetPort`.
### Expose outside of cluster
From `service` manifest: Use port from the `ǹodePort` setting.


# Extras
Here are some nice-to-have settings but not required.

## Ubuntu-server specific:
`.bashrc`:
```
# Vim
EDITOR=vim

# Kubernetes
alias kp="kubectl get pods -A -o wide"
alias kn="kubectl get nodes -A -o wide"
alias k=kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k
```
For laptop-servers, turn off suspend/sleep when lid is closed by uncomment and change in file `/etc/systemd/logind.conf`
```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```
apply changes with 
```
systemctl restart systemd-logind.service
```


## Manjaro setup
This is for my development machine, which isnt part of the cluster. I use Manjaro and KDE-plasma on this one.

### SSH colorscheme
Append or create following in file: `~/.ssh/config`
```
PermitLocalCommand yes
Host <alias of server>
    Hostname <ip of server>
    User <log in as user>
    LocalCommand konsoleprofile ColorScheme=RedOnBlack;TabColor=#FF0000
```
The above will change the terminal color scheme when connecting to the set host. However, it will not change back. To get around that I set it back by masking `ssh` as a function in my shell, see below.\
Append this to `.zshrc`
```
# SSH custom colors
# Mask as function, restore ColorScheme on exit
ssh() {/usr/bin/ssh "$@"; konsoleprofile ColorScheme=Breath  }
```

### Shell scripts
Append this to `.zshrc`
```
# Default
alias l=ls
alias ll="ls -lha"

# SSH
eval "$(ssh-agent)" 1>/dev/null
ssh-add -q /home/nkls/.ssh/github 

# Disable capslock and remap button to 'End'
setxkbmap -option caps:none
xmodmap -e "keycode 66 = End"

# SSH custom colors
# Mask as function, restore ColorScheme on exit
ssh() {/usr/bin/ssh "$@"; konsoleprofile ColorScheme=Breath  }
```

Add `.vimrc`for ssh
