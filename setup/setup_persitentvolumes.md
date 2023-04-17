# Setup Persistent Volumes
Persistent volumes are objects that resides within the cluster and works as a link between a folder on a physical storage device (i.e. SSD).
A persistent volume can be used by multiple pods via the use of persistem volume claims, which ask/claim part of all of the persisten volume object, depending on the claim size.

I will illustrate with an example for the local registry using the `registry` namespace.
For `prometheus` the permission of the local folder that is used on the host has to be changed, `sudo chown 65534:65534 /srv/monitoring/prometheus`
## StorageClass
Storage classes are cluster-objects and cannot be assigned to a namespace.
```
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
## Setup deployment with persistent volume

The following example is a deployment of the local docker image registry where the persistent volumes maps to a folder on the server, the master node `eva` in my case.\
The `persistentVolumeClaim` is defined as a volume in the pod `spec` which then is refered to from the container volume.
Note to self: Do not forget that the `secrets` needs to be created within the same `namespace` as the `deployment` otherwise it cannot find them. This is done when the secrets are defined.

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: image-registry
  namespace: registry
  labels:
    app: image-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: image-registry
  template:
    metadata:
      labels:
        app: image-registry
    spec:
      nodeSelector:
        nodetype: storage
      volumes:
      - name: cert-vol
        secret:
          secretName: cert-secret
      - name: auth-vol
        secret:
          secretName: auth-secret
      - name: repo-vol
        persistentVolumeClaim:
          claimName: docker-repo-pvc
      containers:
        - image: registry:2.7.0
          name: image-registry
          imagePullPolicy: IfNotPresent
          env:
          - name: REGISTRY_AUTH
            value: "htpasswd"
          - name: REGISTRY_AUTH_HTPASSWD_REALM
            value: "Registry Realm"
          - name: REGISTRY_AUTH_HTPASSWD_PATH
            value: "/auth/htpasswd"
          - name: REGISTRY_HTTP_TLS_CERTIFICATE
            value: "/cert/tls.crt"
          - name: REGISTRY_HTTP_TLS_KEY
            value: "/cert/tls.key"
          ports:
            - containerPort: 5000
          volumeMounts:
          - name: cert-vol
            mountPath: "/cert"
            readOnly: true
          - name: auth-vol
            mountPath: "/auth"
            readOnly: true
          - name: repo-vol
            mountPath: "/var/lib/registry"
```

And the `service` has to be in the same namespace aswell

```
---
apiVersion: v1
kind: Service
metadata:
  name: image-registry
  namespace: registry
spec:
  selector:
    app: image-registry
  type: NodePort
  ports:
    - port: 5000
      targetPort: 5000
      protocol: TCP
      nodePort: 31320
  clusterIP: 10.106.32.26
```
