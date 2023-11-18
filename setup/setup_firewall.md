# Setup UFW - Uncomplicated FireWall
This guide shows how to work with the UFW.
<!--toc-->


- [Install ufw](#install-ufw)
  * [Settings](#settings)
  * [Open ports](#open-ports)
    + [Control-plane](#control-plane)
    + [Worker nodes](#worker-nodes)
  * [Overview ports](#overview-ports)
    + [Public ports](#public-ports)
    + [Local ports](#local-ports)


# Install ufw
```
sudo apt install ufw -y
sudo ufw enable
```

## Settings
Open `/etc/default/ufw` and change following if needed:
```
IPV6=yes
```

Disable/enable if you had to change
```
sudo ufw disable && sudo ufw enable
```

Configure the default settings to only allow inbound connection at manually allowed ports
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```
## Open ports

See [Kubernetes documentation](https://kubernetes.io/docs/reference/networking/ports-and-protocols/) for more details.

### Control-plane
```
# Open the SSH-port
sudo ufw allow <YOU SSH PORT>/tcp

# For https, e.g. Kubeflow
sudo ufw allow https
sudo ufw allow 443

# Open ports for local docker image registry
# Internal
sudo ufw allow 5000/tcp
# External
sudo ufw allow 31320/tcp

# Open ports for Control Plane
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

# Open port for kubernetes metric server (if untainted or no worker node)
sudo ufw allow 4443/tcp

# Depending on what CNI is used:

# Flannel (used here)
sudo ufw allow 8285/udp
sudo ufw allow 8472/udp

# Calico (previous versions)
#sudo ufw allow 179/tcp
#sudo ufw allow 4789/udp
#sudo ufw allow 4789/tcp
#sudo ufw allow 2379/tcp
```

### Worker nodes

```
# Open port for SSH
sudo ufw allow <YOUR SSH PORT>/tcp

# For https, e.g. Kubeflow
sudo ufw allow https
sudo ufw allow 443

# Open ports for Kubernetes
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp

# Open port for kubernetes metric server
sudo ufw allow 4443/tcp

# Open port for Kubeflow
sudo ufw allow 8443/tcp

# Open port for Prometheus
sudo ufw allow 30000/tcp
sudo ufw allow 8080/tcp

# Open ports for NFS
sudo ufw allow 111/tcp
sudo ufw allow 2049/tcp
sudo ufw allow 6666/tcp

# Depending on what CNI is used:

# Flannel (used here)
sudo ufw allow 8285/udp
sudo ufw allow 8472/udp

# Calico (previous versions)
#sudo ufw allow 179/tcp
#sudo ufw allow 4789/udp
#sudo ufw allow 4789/tcp
#sudo ufw allow 2379/tcp
```

When ports are set, restart the ufw for good measure.
```
sudo systemctl restart ufw
```


## Overview ports
### Public ports
| Service | Port |
|---|---|
|Grafana|32000|
|Image Registry|31320|
|Kubeflow|31000|
|SSH|\<YOUR SSH PORT>|

### Local ports
| Service | Port |
|---|---|
|Grafana|3000|
|Image Registry|5000|
|Kubeflow|8443|
|Prometheus|30000|

