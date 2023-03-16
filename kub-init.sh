#!/bin/bash
# Worker nodes
REMOTE_HOST=192.168.1.102

# Get local info
IPADDR="192.168.1.80"
# IPADDR=$(nmcli device show | grep IP4.ADDRESS | head -1 | awk '{print $2}' | rev | cut -c 4- | rev)
NODENAME=$(hostname -s)
export KUBELET_EXTRA_ARGS=--node-ip=$IPADDR
# echo ">>AUTOMATIC IP FOUND:"
echo ">>IP ADDRESS: $IPADDR"
echo ">>HOSTNAME: $NODENAME"

# CNI
#Flannel
POD_CIDR="10.244.0.0/16"
# Calico
# POD_CIDR="192.168.0.0/16"

sudo swapoff -a

# Clean up old files
sudo rm /var/lib/etcd/ -rf
sudo kubeadm reset -f 


# Start Cri-o
sudo systemctl restart crio.service
# Start Kubelet
sudo systemctl restart kubelet.service
# sudo systemctl stop kubelet.service
# sudo systemctl start kubelet.service
# Initiate the control-plane
sudo kubeadm init \
    --apiserver-advertise-address=$IPADDR  \
    --apiserver-cert-extra-sans=$IPADDR  \
    --pod-network-cidr=$POD_CIDR \
    --node-name=$NODENAME \
    --ignore-preflight-errors=swap \
    --cri-socket=unix:///var/run/crio/crio.sock \
    # --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \
    # --cri-socket=unix:///var/run/cri-dockerd.sock

# Copy new config
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# export KUBECONFIG=/etc/kubernetes/kubelet.conf
# export KUBECONFIG=/etc/kubernetes/admin.conf

# Start the cluster by deploying a pod network
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Install metric server
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# Create join-command-file for workers
# TODO: $USER instead of hardcode
echo cd /home/nkls/tools > ~/tools/kub-join.sh
echo sudo systemctl restart crio.service >> ~/tools/kub-join.sh
# echo sudo systemctl restart kubelet.service >> ~/tools/kub-join.sh
echo sudo tar -xf cni_files.tar -C /etc/cni/ >> ~/tools/kub-join.sh
echo sudo mkdir /run/systemd/resolve/ >> ~/tools/kub-join.sh
echo sudo ln -sf /etc/resolv.conf /run/systemd/resolve/ >> ~/tools/kub-join.sh
echo sudo kubeadm reset -f --cri-socket=unix:///var/run/crio/crio.sock >> ~/tools/kub-join.sh 
echo -n "sudo " >> ~/tools/kub-join.sh
join=$(kubeadm token create --print-join-command)
echo ${join:0:13}--cri-socket=unix:///var/run/crio/crio.sock/ ${join:13} >> ~/tools/kub-join.sh
# kubeadm token create --print-join-command >> ~/tools/kub-join.sh 
# truncate -s -1 ~/tools/kub-join.sh
# echo "--cri-socket=unix:///var/run/crio/crio.sock/" >> ~/tools/kub-join.sh 
echo cd - >> ~/tools/kub-join.sh

# Tar net.d files 
sudo tar -C /etc/cni -cvf cni_files.tar net.d

# Send files to worker nodes over SSH
while true; do
    
ping -c1 $REMOTE_HOST 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]
then
    # Copy files to worker via ssh
    sudo scp -P 33445 /home/nkls/tools/kub-join.sh /home/nkls/tools/cni_files.tar nkls@$REMOTE_HOST:/home/nkls/tools/
    break
fi

read -p "Cannot reach $REMOTE_HOST, retry? (y/n)" yn
    case $yn in
        [Yy]* ) continue;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

rm /home/niklas/tools/cni_files.tar -f

# Set up for cri-o on manjaro
# On worker:
# set up symlink from /etc/resolv.conf -> /run/systemd/resolve/resolv.conf 
# On master:
# kubectl label node <node-name> node-role.kubernetes.io/
# kubectl label node nkls-asus node-role.kubernetes.io/worker=worker
