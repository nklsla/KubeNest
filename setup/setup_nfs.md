# Setup Network Filesystem Service (Dynamic Provisioner)
This guide explain how to set up a dynamic provisioner-nfs server.\
A seperate nfs-disk is needed or recommended to let all nodes access the same disk on the network/cluster.

## Install and create directories
```
sudo apt install nfs-kernel-server -y

sudo mkdir /srv/nfs
sudo chown nobody:nogroup /srv/nfs
sudo chmod g+rwxs /srv/nfs/
```
## Share the directories
```
echo -e "/srv/nfs\t192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/export
sudo exportfs -av
```
## Enable Firewall
Enable portmapper and nfs access respective
```
sudo ufw allow 111/tcp
sudo ufw allow 2049/tcp
sudo ufw allow 6666/tcp
```
Set mountd and allow access

```
echo -e "mountd\t\t6666/tcp" | sudo tee -a /etc/services
echo -e "mountd\t\t6666/udp" | sudo tee -a /etc/services

```

## Restart NFS
```
sudo systemctl restart nfs-kernel-server
/sbin/showmount -e localhost
```
should output
```
Export list for localhost:
/srv/nfs 192.168.1.0/24
```

## Install NFS client on worker cluster nodes
SSH into each node and install the client
```
sudo apt update
sudo apt install nfs-common -y
```
Check connection 
```
# Use the NFS servers ip
/sbin/showmount -e 192.168.1.80 
```
should output
```
Export list for 192.168.1.80:
/srv/nfs 192.168.1.0/24
```

## Install Helm
This should be for cluster wide setup
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
## install nfs-subdir-external-provisioner and Chart for NFS
Installs `nfs-subdir-external-provisioner` and use `helm` to install/start a `Chart` for NFS.
This will create a `storageClass` for kubernetes that will handle creation, deletion and archival of the volume. It will create a deployment as well.
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.1.80 --set nfs.path=/srv/nfs --set storageClass.onDelete=true
```

## Create a PersistentVolumeClaim for NFS
This claim can be used for `pods`.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 3Gi

```
