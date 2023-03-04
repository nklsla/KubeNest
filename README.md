# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


TODO: UPDATE THE TOC
- [k8s-cluster](#k8s-cluster)
  * [My setup](#my-setup)
    + [Tools](#tools)
    + [Master (Control-plane)](#master--control-plane-)
    + [Node 1](#node-1)
    + [Node 2 (temporary)](#node-2--temporary-)
  * [Install master node](#install-master-node)
  * [Ubuntu-server specific:](#ubuntu-server-specific-)
    + [Mark manual work](#mark-manual-work)
  * [Install worker node](#install-worker-node)
  * [Start up](#start-up)
  * [Extras](#extras)
    + [SSH colorscheme](#ssh-colorscheme)

## My setup
### Tools
> Ubuntu server 22.04\
> Manjaro 22.04\
> Kubectl\
> Kubeadm\
> CRI-O (CRI)\
> crun \
> Flannel (CNI)\
> Docker (Develope and registry)\
> Neovim

### Master (Control-plane)
OS: Ubuntu server 22.04.2\
CPU: 64-bit Intel i3-2310M CPU @ 2.10GHz, 4 cores \
GPU: -
RAM: 4 GB \
DISK: 700GB, HDD (yes..)


### Node 1
OS Ubuntu server 22.04.2\
CPU: \
GPU: nVIDIA GTX 960M?\
RAM: \
DISK:


### Node 2 (temporary)
OS Ubuntu 22.04 \
CPU: \
GPU: \
RAM: \
DISK:


## Install master node
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
For development purpose here are my settings for manjaro\
### SSH colorscheme
Append or create following in file: `~/.ssh/config`
```
Host <alias of server>
    Hostname <ip of server>
    User <log in as user>
    LocalCommand konsoleprofile ColorScheme=RedOnBlack;TabColor=#FF0000
PermitLocalCommand yes
```


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
