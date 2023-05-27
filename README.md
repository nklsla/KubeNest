# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


__TODO: Security for registry, login should be more sophisticated__\
__TODO: Setup Grafana__\
__TODO: Setup KubeFlow__


## Overview
- Kubectl 1.26.2-00
- Kubeadm 1.26.2-00
- cri-o 1.26
- crun
- Flannel
- Local image registry (Docker)
- Prometheus & Grafana
- ((KubeFlow))

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


### Worker Node 2 
OS: Ubuntu 22.04 \
CPU: \
GPU: \
RAM: \
DISK:


# Setup guides
[Setup cluster](setup/setup_cluster.md)\
[Setup local image registry](setup/setup_registry.md)\
[Setup monitoring](setup/setup_prometheus.md)\
[Setup persitent volumes](setup/setup_persitentvolumes.md)\
[Setup firewall](setup/setup_firewall.md)\
[Setup SSH](setup/setup_ssh.md)\
[Setup extras](setup/setup_extra.md)\
[Setup NFS](setup/setup_nfs.md)

__TODO:__
- Setup Jobs/Queue/parallel
- Setup KubeFlow

## Start up
- Run `kub-init.sh`
-- Assign node ips and send `kub-join.sh`
- SSH join commands to nodes 
- Run join commands from master

