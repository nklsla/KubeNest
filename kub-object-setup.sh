# Create cluster wide objects
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create -f $DIR/manifests/cluster-objects/

# Label nodes
kubectl label nodes eva nodetype=storage
kubectl label nodes nkls-asus cpu=true gpu=true node-role.kubernetes.io/worker=worker

# Start NFS server
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.1.80 --set nfs.path=/srv/nfs --set storageClass.onDelete=true

