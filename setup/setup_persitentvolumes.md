# Setup Persistent Volumes
Persistent volumes are objects that resides within the cluster and works as a link between a folder on a physical storage device (i.e. SSD).
A persistent volume can be used by multiple pods via the use of persistem volume claims, which ask/claim part of all of the persisten volume object, depending on the claim size.

I will illustrate with an example for the local registry using the `registry` namespace.
## StorageClass
```
Storage classes are cluster-objects and cannot be assigned to a namespace.
---
# Create Storage class for local persitent volume
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```
## PersistentVolume
Persistent volumes are cluster-objects and cannot be assigned to a namespace.
```
# Declare volume for registry
apiVersion: v1
kind: PersistentVolume
metadata:
  name: docker-repo-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: "/srv/kube-data/repo"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - eva
```

## PersistentVolumeClaim
Create the claim for the persitent volume, this object can be in a namespace and must be in the same namespace as the pod using the claim.
Here the claim requests the full size of the volume, this does not have to be the case.
```
# Declare the volume claim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: docker-repo-pvc
  namespace: registry
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 5Gi
```
