# Define variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create cluster wide objects
echo ""
echo "###### Start cluster objects ######"
kubectl create namespace storage
kubectl create -f $DIR/manifests/cluster-objects/

# Label nodes
echo ""
echo "###### Label nodes  ######"
kubectl label nodes eva nodetype=storage
kubectl label nodes nkls-asus cpu=true node-role.kubernetes.io/worker=worker

# Start docker registry
echo ""
echo "###### Start docker registry ######"
source $DIR/scripts/start-registry.sh

# Start Promoetheus and Grafana
echo ""
echo "###### Start monitoring with Prometheus & Grafana ######"
source $DIR/scripts/start-monitoring.sh

# Start NFS server
#echo ""
#echo "###### Start Network File System ######"
#helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.1.80 --set nfs.path=/srv/nfs --set storageClass.onDelete=true

# Start nvidia gpu operator
echo ""
echo "###### Start Nvidia GPU Operator ######"
source $DIR/scripts/start-gpu-operator.sh
#helm install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator --set driver.enabled=false
