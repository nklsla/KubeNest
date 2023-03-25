# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


__TODO: UPDATE THE TOC__\
__TODO: Apply secure connections, Firewall,TLS etc.__\
__TODO: Security for registry, login should be more sophisticated__\
__TODO: Install nfs-commmon on all nodes for nfs-persistentvolume `sudo apt install nfs-common__ \
https://www.linuxtechi.com/configure-nfs-persistent-volume-kubernetes/ \
https://www.linuxtechi.com/setup-nfs-server-on-centos-8-rhel-8/ \
__TODO: Set up Prometheus and Grafana for monitoring__ \
https://devopscube.com/setup-prometheus-monitoring-on-kubernetes

## Overview
- Kubectl
- Kubeadm
- cri-o
- crun
- Flannel
- Docker as local registry

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
[Setup the cluster](setup_cluster.md)\
[Setup local docker registry](setup_registry.md)\
[Setup extras](setup_extra.md)\
[Setup Firewall](setup_firewall.md)\
[Setup SSH](setup_ssh.md)

__TODO:__
- Setup Persistent volume / NFS
- Setup Prometheus
- Setup Grafana
- Setup Jobs/Queue/parallel

## Start up
- Run `kub-init.sh`
-- Assign node ips and send `kub-join.sh`
- SSH join commands to nodes 
- Run join commands from master

