# Define variables

# Start up order
# -1. Start up cluster
# 0. Config-file, Label nodes & other settings
# 3. Metrics server
# 1. NFS / Storage
# 1. Dynamic pvc provisioner
# 2. Local registry

# -- optional order below-- 

# 4. Monitoring 
# 5. GPU-operator
# 6. Kubeflow


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set environment variables from config
source $DIR/scripts/start-cfg.sh

echo ""
echo "###### Label Nodes  ######"
kubectl label nodes ${CTLPLN_NODE} nodetype=storage
kubectl label nodes ${WORKER_NODE_1} node-role.kubernetes.io/worker=worker
kubectl label nodes ${WORKER_NODE_2} node-role.kubernetes.io/worker=worker
kubectl label nodes ${WORKER_NODE_3} node-role.kubernetes.io/worker=worker

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ""
echo "###### Start Metrics Server ######"
kubectl create -f <(envsubst <$DIR/manifests/cluster-objects/metric-server.yaml)

echo ""
echo "###### Start NFS Server ######"
kubectl create namespace storage
kubectl create -f <(envsubst <$DIR/manifests/cluster-objects/nfs.yaml)

echo ""
echo "###### Start NFS Subdir External Provisioner  ######"
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=${NFS_CLUSTER_IP} --set nfs.path=/subdir-ext --set storageClass.onDelete=true

echo ""
echo "###### Start Docker Registry ######"
source $DIR/scripts/start-registry.sh

echo ""
echo "###### Start Monitoring: Prometheus & Grafana ######"
source $DIR/scripts/start-monitoring.sh

echo ""
echo "###### Start Nvidia GPU Operator ######"
source $DIR/scripts/start-gpu-operator.sh
helm install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator --set driver.enabled=false

echo ""
echo "###### Start Kubeflow ######"
source $DIR/scripts/start-kubeflow.sh 
