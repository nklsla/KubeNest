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
Install nfs-commmon on all nodes for nfs-persistentvolume `sudo apt install nfs-common
........


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

Add user authentication to be able to use the docker registry.
```
sudo touch auth/htpasswd
sudo chmod 777 auth/htpasswd
docker run --rm --entrypoint htpasswd registry:2.6.2 -Bbn myuser mypasswd > auth/htpasswd
sudo chmod 644 auth/htpasswd
```

Create secretes in kubernetes to mount the certificates and password.
```
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd
```




## Create PersistentVolume and Claim

Create a persistent volume in kubernetes. For my set up I run this on the master node.
```
sudo mkdir /srv/kube-data/registry
sudo echo "NFS Storage" | sudo tee -a /srv/kube-data/registry/index.html
```
Create a `registry-nfs-pv-pvc.yaml` for kubernetes
```
# Declare nfs volume for registry
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 5Gi
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
---
# Declare the volume claim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteMany
  resources: mount failed: exit statu
    requests:
      storage: 5Gi
```

Create and clain the volume
```
kubectl create -f registry-nfs-pv-pvc.yaml
# Validate
kubectl get pv
kubectl get pvc
```

## Create registry pod & service
This will create a pod using the docker registry image and start a service to expose it to the cluster.
```
---
apiVersion: v1
kind: Pod
metadata:
  name: docker-registry-pod
  labels:
    app: registry
spec:
  containers:
    - name: registry
      image: registry:2.7.0
      volumeMounts:
        - name: repo-vol
          mountPath: "/var/lib/registry"
        - name: cert-vol
          mountPath: "/certs"
          readOnly: true
        - name: auth-vol
          mountPath: "/auth"
          readOnly: true
      env:
        - name: REGISTRY_AUTH
          value: "htpasswd"
        - name: REGISTRY_AUTH_HTPASSWD_REALM
          value: "Registry Realm"
        - name: REGISTRY_AUTH_HTPASSWD_PATH
          value: "/auth/htpasswd"
        - name: REGISTRY_HTTP_TLS_CERTIFICATE
          value: "/cert/tls.crt"
        - name: REGISTRY_HTTP_TLS_KEY
          value: "/cert/tls.key"
  volumes:
    - name: repo-vol
      persistentVolumeClaim:
        claimName: nfs-pvc
    - name: cert-vol
      secret:
        secretName: cert-secret
    - name: auth-vol
      secret:
        secretName: auth-secret
---
apiVersion: v1
kind: Service
metadata:
  name: docker-registry-pod
spec:
  selector:
    app: registry
  ports:
    - port: 5000
      targetPort: 5000
```

Start the pod and service
```
kubectl create -f registry-service-pod.yaml
```
## Expose the registry
Once the service is up and running. This will make sure nodes within the cluster can access it and machine outside should be able to access as well, to push in new code.
### Expose within the cluster

### Expose outside of cluster


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
