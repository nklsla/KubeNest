# Setup Network Filesystem Service
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

