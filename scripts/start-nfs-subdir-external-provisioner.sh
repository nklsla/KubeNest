# Start nfs automatic PVC-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=${NFS_CLUSTER_IP} --set nfs.path=/subdir-ext --set storageClass.onDelete=true
