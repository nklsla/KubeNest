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

# Initiate the control-plane
sudo kubeadm init \
    --apiserver-advertise-address=$IPADDR  \
    --apiserver-cert-extra-sans=$IPADDR  \
    --pod-network-cidr=$POD_CIDR \
    --node-name=$NODENAME \
    --ignore-preflight-errors=swap \
    --cri-socket=unix:///var/run/crio/crio.sock \
    # --container-runtime-endpoint unix:///var/run/cri-dockerd.sock \

# Copy new config
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Start the cluster by deploying a pod network
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Install metric server
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# Initialize workers
echo "######################"
echo "START WORKER NODES"
echo "######################"
# Create join-command-file for workers
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo 'DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"' > $DIR/kub-join.sh
echo sudo systemctl restart crio.service >> $DIR/kub-join.sh
echo sudo tar -xf '$DIR'/cni_files.tar -C /etc/cni/ >> $DIR/kub-join.sh
echo sudo mkdir /run/systemd/resolve/ >> $DIR/kub-join.sh
echo sudo ln -sf /etc/resolv.conf /run/systemd/resolve/ >> $DIR/kub-join.sh
echo sudo kubeadm reset -f --cri-socket=unix:///var/run/crio/crio.sock >> $DIR/kub-join.sh 
echo -n "sudo " >> $DIR/kub-join.sh
join=$(kubeadm token create --print-join-command)
echo ${join:0:13}--cri-socket=unix:///var/run/crio/crio.sock ${join:13} >> $DIR/kub-join.sh

# Tar net.d files 
sudo tar -C /etc/cni -cvf $DIR/cni_files.tar net.d

# Send files to worker nodes
while true; do
    
ping -c1 $REMOTE_HOST 1>/dev/null 2>/dev/null
SUCCESS=$?

if [ $SUCCESS -eq 0 ]
then
    # Send files to workers
    echo "Sending files.."
    scp -P 33445 $DIR/kub-join.sh $DIR/cni_files.tar nkls@$REMOTE_HOST:/tmp/

    # Execute the join-file 
    echo "Run join-script on worker: $REMOTE_HOST"
    ssh -t -p 33445 nkls@$REMOTE_HOST "source /tmp/kub-join.sh"
    break
fi

read -p "Cannot reach $REMOTE_HOST, retry? (y/n)" yn
    case $yn in
        [Yy]* ) continue;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

rm $DIR/cni_files.tar -f
