# k8s-cluster
My home-setup of a local kubernetes cluster and container registry.\
The inital purpose for this project is to learn more about backend, servers, containers and container orcherstration.\
My first approach is to use it for machine learning: Distributed training, deploy models, data processing and visualize status/progress/results.\
All development is done on a seperate machine and is pushed up to the local container registry or via SSH.


__TODO: Security for registry, login should be more sophisticated__\
__TODO: Setup Grafana__\
__TODO: Setup KubeFlow__


## Overview
- Kubelet 1.26.2-00
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
OS: \
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


## Troubleshoot
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
