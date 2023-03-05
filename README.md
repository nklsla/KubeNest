# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


__TODO: UPDATE THE TOC__
__TODO: Apply secure connections, TLS between nodes__
__TODO: Set up local image registry__

## My setup
### Tools
- Ubuntu server 22.04\
- Manjaro 22.04\
- Kubectl\
- Kubeadm\
- CRI-O (CRI)\
- crun \
- Flannel (CNI)\
- Docker (Develope and registry)\
- Neovim

### Master Node (Control-plane)
OS: Ubuntu server 22.04.2\
CPU: 64-bit Intel i3-2310M CPU @ 2.10GHz, 4 cores \
GPU: -
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


## Setup All Nodes
The following has to be done on all nodes.\
Most of these steps and instructions have I shamelessly taken from [Kubernets](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) and various guides I've found. 

Enable kernel modules
```
# Enabling kernel modules (overlay and br_netfilter)
sudo modprobe overlay
sudo modprobe br_netfilter
```

........


### Mark manual work
https://adamtheautomator.com/cri-o/
run setup-script.sh

## Install worker node
turn off sleep when lid closes
turn off screen when lid closes

## Start up
-initiazion script
-SSH join commands to nodes
-Run join commands from master


# Container Registry
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

## Create PersistentVolume
Create a persistent volume in kubernetes. For my set up I will have this on the master node.
```
sudo mkdir /srv/kube-data/registry
sudo echo "NFS Storage" | sudo tee -a /srv/kube-data/registry/index.html
```
Create a `nfs-pv.yaml` for kubernetes
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /srv/kube-data/registry
    server: 192.168.1.80
```
Create the volume
```
kubectl create -f nfs-pv.yaml
kubectl get pv
```

## Create PersistentVolumeClaim
Create `nfs-pvc.yaml`
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```

and claim/mount the volume on the master node
```
kubectl create -f nfs-pvc.yaml
```
continue this: \
https://www.linuxtechi.com/configure-nfs-persistent-volume-kubernetes/ \
https://www.linuxtechi.com/setup-private-docker-registry-kubernetes/



# Extras
Here are some nice-to-have settings but not required.

## Ubuntu-server specific:
`.bashrc`:
```
# Kubernetes
alias kp="kubectl get pods -A -o wide"
alias kn="kubectl get nodes -A -o wide"
```
For laptop-servers, dont suspend/sleep if lid is closed:\
Uncomment and change in file `/etc/systemd/logind.conf`:
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
Host <alias of server>
    Hostname <ip of server>
    User <log in as user>
    LocalCommand konsoleprofile ColorScheme=RedOnBlack;TabColor=#FF0000
PermitLocalCommand yes
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
