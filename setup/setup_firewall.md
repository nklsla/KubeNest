# Setup UFW - Uncomplicated FireWall
This guide gives an overview of all ports that are required for this project.

## Install and/or enable ufw
Install the `uncomplicated firewall`
```
sudo apt install ufw -y
sudo ufw enable
```

Apply these settings to `IP 6`\
open and make sure to have following in `/etc/default/ufw`:
```
IPV6=yes
```

if you had to change:
```
sudo ufw disable && sudo ufw enable
```

Configure the default settings:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Requires SSH service to be running (will allow port 22 by default)
sudo ufw allow ssh
```
## Open ports

[Kubernetes documentation](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)

### Control-plane
```
# Open the SSH-port
sudo ufw allow 33445/tcp

# WILL UNCOMMENT IF NEEDED.. Kubernetes service listens to this port thought..
#sudo ufw allow https
#sudo ufw allow 443

# Open ports for local docker image registry
sudo ufw allow 5000/tcp
sudo ufw allow 31320/tcp

# Open ports for Control Plane
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

# Open port for kubernetes metric server (if untainted or no worker node)
sudo ufw allow 4443/tcp

# Different ports for different CNI's

# Flannel
sudo ufw allow 8285/udp
sudo ufw allow 8472/udp

# Calico
#sudo ufw allow 179/tcp
#sudo ufw allow 4789/udp
#sudo ufw allow 4789/tcp
#sudo ufw allow 2379/tcp
```

### Worker nodes

```
# Open port for SSH
sudo ufw allow 33445/tcp

# For https, e.g. Kubeflow
#sudo ufw allow https
#sudo ufw allow 443

# Open ports for Kubernetes
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp

# Open port for kubernetes metric server
sudo ufw allow 4443/tcp

# Open port for Prometheus
sudo ufw allow 30000/tcp

# Different ports for different CNI's
# Flannel
sudo ufw allow 8285/udp
sudo ufw allow 8472/udp

# Calico
#sudo ufw allow 179/tcp
#sudo ufw allow 4789/udp
#sudo ufw allow 4789/tcp
#sudo ufw allow 2379/tcp
```


and restart the service
```
sudo systemctl restart ufw
```


## Ports for public access
| Service | Port |
|---|---|
|Grafana|32000|
|Image Registry|31320|
|Kubeflow|31000|
|SSH|33445|
