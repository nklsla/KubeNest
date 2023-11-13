# KubeNest
This is my setup for a Kubernetes homelab that's running on some left-over computers I've collected.<br>The name KubeNest is just a wordplay on Google Nest and Kubernetes for being a homelab.

This project started out when I wanted to do my coding projects on my small comfortable laptop and let my other more powerful bulkier machine do the all the work. <br>
Somehow it got out of hand and I ended up setting up a Kubernetes cluster. So now I have a homelab of a local Kubernetes cluster with Kubeflow, Docker Image Registry, NFS-server and more. 

Have in mind that I had no prior knowledge about any of these systems beforehand so there most likely some things that might not completely add up. \
The initial purpose for this project was to __learn__ more about backend, servers, containers, container orcherstration and MLOps. However, one of the best ways to learn is to teach, so I figured I should document each step to have something to reflect over while setting it up. I figured it might as well share this for anyone who looking for help or inspiration.

This project is focused on running in a local network all thought some parts are exposed publicly. The "public parts" were mainly done to enable work on this project while I was not home from time to time.

# Table of Content
<!--toc-->


- [System overview](#system-overview)
  * [Specifications](#specifications)
    + [Cluster Components](#cluster-components)
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
## Specifications
The cluster is composed by the following componentes

### Cluster Components
- Kubelet 1.25.10
- Kubectl 1.25.10
- Kubeadm 1.25.10
- cri-o 1.26
- crun
- Flannel 0.21.5
- KubeFlow 1.7
- Docker image registry 2.7.0
- Prometheus
- Grafana
- NFS

### Master Node (Control-plane)
OS: Ubuntu server 22.04.2\
CPU: 64-bit Intel i3-2310M CPU @ 2.10GHz, 4 cores \
GPU: - \
RAM: 4 GB \
DISK: 700 GB, HDD \
TYPE: Laptop


### Worker Node 1
OS: Ubuntu server 22.04.2 \
CPU: 64-bit Intel i7-6700HQ CPU @ 2.60GHz, 8 cores \
GPU: NVIDIA GeForce GTX 960M, 2048 MB GDDR5, 640 CUDA cores (5.0) \
RAM: 8 GB \
DISK: 240 GB, SSD \
TYPE: Laptop

### Worker Node 2
OS: Ubuntu server 22.04.2 \
CPU: 64/bit Intel i5-4690K @ 3.50GHz, 4 cores \
GPU: NVIDIA GTX 1070, 8 GB GDDR5, 1920 CUDA cores \
RAM: 16 GB, DIMM DDR3 1600MHz\
DISK: 250 GB, SSD\
TYPE: Desktop

<!-- ### Worker Node 2  -->
<!-- OS: Ubuntu desktop 22.04.2 \ -->
<!-- CPU: 64-bit Intel i7-10850H CPU @ 2.70GHz, 6 cores \ -->
<!-- GPU: NVIDIA Quadro RTX4000, 8192 MB GDDR6, 2304 CUDA cores, 288 Tensor cores, 36 RT cores \ -->
<!-- RAM: 32 GB \ -->
<!-- DISK: 250 GB, SSD -->


# Install
This project contains `submodules` (Kubeflow). To clone with submodules 
```
git clone --recurse-submodules git@github.com:nklsla/KubeNest.git
```
## Prerequisites 
- [Helm](https://helm.sh/docs/intro/install/)
- Enable SSH on all machines
- Ubuntu 22.04
- [Setup `scripts/parameters.sh`](scripts/parameters.sh)

## Setup guides
- [Setup SSH](setup/setup_ssh.md)
- [Setup Kubernetes](setup/setup_cluster.md)
- [Setup Firewall](setup/setup_firewall.md)
- [Setup NFS](setup/setup_nfs.md)
- [Setup Docker Image Registry](setup/setup_registry.md)
- [Setup Monitoring](setup/setup_prometheus.md)
- [Setup Kubeflow](setup/setup_kubeflow.md)
- [Setup GPU-operator](setup/setup_gpu.md)
- [Setup Extras](setup/setup_extra.md)
<!-- - [Setup persitent volumes](setup/setup_persitentvolumes.md) -->

## Start up

- Run [`kub-init.sh`](./kub-init.sh) to initialize the cluster to its bare minimum, connecting workers.
- Run [`kub-start.sh`](./kub-start.sh) to start up all services:
  - _sets parameters_
  - NFS services
  - Metrics-server
  - Docker Image Registry
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
# If not installed
sudo apt install bridge-utils

sudo ip link set cni0 down
sudo brctl delbr cni0  
```
