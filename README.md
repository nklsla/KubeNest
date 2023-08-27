# k8s-cluster
This project started out when I wanted to do my coding on my small comfortable machine and let my other more powerful bulkier machine do the all the work.
Somehow it got out of hand and I ended up setting up a `kubernetes` cluster with `kubeflow`. <br>
So now I have a homelab of a local `kubernetes` cluster with `kubeflow`, `docker image registry`, `nfs-server` and more.

The initial purpose for this project is to __learn__ more about backend, servers, containers, container orcherstration and MLOps. Have in mind that I had no prio knowledge about any of these systemes on before hand so there might be some things that might not completely add up. One of the best ways to learn is to teach, so I figured I should create a guide to have something to reflect over while setting it up. 

This project is mainly focused on running as a local service. All thought some parts are exposed publicly, these parts I mainly did to enable work on this project while I was not home from time to time.

# Table of Content
<!--toc-->

- [System overview](#system-overview)
  * [Details](#details)
    + [Master Node (Control-plane)](#master-node-control-plane)
    + [Worker Node 1](#worker-node-1)
    + [Worker Node 2](#worker-node-2)
- [Install](#install)
  * [Prerequisites](#prerequisites)
  * [Setup guides](#setup-guides)
  * [Start up](#start-up)
  * [Troubleshoot](#troubleshoot)


# System overview

![System overview](diagrams/System-diagram.drawio.svg)
<br>
<a href="https://app.diagrams.net/#Hnklsla%2Fk8s-cluster%2Fmain%2Fdiagrams%2FSystem-diagram.drawio.svg" target="_blank" rel="noopener noreferrer">Edit diagram in draw.io</a>
## Details
The cluster is composed by the following componentes
- Kubelet 1.25.10
- Kubectl 1.25.10
- Kubeadm 1.25.10
- cri-o 1.26
- crun
- Flannel 0.21.5
- [KubeFlow 1.7](manifests/kubeflow/manifests)
- Docker image registry (2.7.0)
- Prometheus
- Grafana
- NFS

### Master Node (Control-plane)
OS: Ubuntu server 22.04.2\
CPU: 64-bit Intel i3-2310M CPU @ 2.10GHz, 4 cores \
GPU: - \
RAM: 4 GB \
DISK: 700 GB, HDD (yes..)


### Worker Node 1
OS: Ubuntu server 22.04.2 \
CPU: 64-bit Intel i7-6700HQ CPU @ 2.60GHz, 8 cores \
GPU: NVIDIA GeForce GTX 960M, 2048 MB GDDR5, 640 CUDA cores (5.0) \
RAM: 8 GB \
DISK: 240 GB, SSD


### Worker Node 2 
OS: Ubuntu desktop 22.04.2 \
CPU: 64-bit Intel i7-10850H CPU @ 2.70GHz, 6 cores \
GPU: NVIDIA Quadro RTX4000, 8192 MB GDDR6, 2304 CUDA cores, 288 Tensor cores, 36 RT cores \
RAM: 32 GB \
DISK: 250 GB, SSD


# Install
This project contains `submodules`. To clone with submodules 
```
git clone --recurse-submodules git@github.com:nklsla/k8s-cluster.git
```
## Prerequisites 
- Helm
- SSH setup on machines
- Ubuntu 

## Setup guides
- [Setup cluster](setup/setup_cluster.md)
- [Setup firewall](setup/setup_firewall.md)
- [Setup NFS](setup/setup_nfs.md)
- [Setup local image registry](setup/setup_registry.md)
- [Setup monitoring](setup/setup_prometheus.md)
- [Setup persitent volumes](setup/setup_persitentvolumes.md)
- [Setup Kubeflow](setup/setup_kubeflow.md)
- [Setup extras](setup/setup_extra.md)
- [Setup SSH](setup/setup_ssh.md)

## Start up
- Run `kub-init.sh` to initialize the cluster to its bare minimum, including workers
- Start other services
  - NFS service
  - Docker image registry
  - Metric systems
  - GPU-operator
  - Kubeflow
  - Prometheus
  - Grafana
 






## Troubleshoot
Issue for `kubernetes 1.25.10-00`: \
When resetting the cluster via `kubeadm reset` the `cni` might fail giving following error message on `kubectl describe pods coredns-###`:
```
Events:
  Type     Reason                  Age                   From               Message
  ----     ------                  ----                  ----               -------
  Normal   Scheduled               12m                   default-scheduler  Successfully assigned kube-system/coredns-565d847f94-klvn6 to eva
  Warning  FailedCreatePodSandBox  12m                   kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_coredns-565d847f94-klvn6_kube-system_86d1ad84-5581-4164-bb9d-89b3e9a71f25_0(c6ad012ffda7373a48930d806ea2068629504240f72fb35b6eed87197fff194f): error adding pod kube-system_coredns-565d847f94-klvn6 to CNI network "cbr0": plugin type="flannel" failed (add): failed to delegate add: failed to set bridge addr: "cni0" already has an IP address different from 10.244.0.1/24
```
Try this
```
sudo ip link set cni0 down
sudo brctl delbr cni0  
```
if `brctl` is not "found" you have to install 
```
sudo apt install bridge-utils
```
