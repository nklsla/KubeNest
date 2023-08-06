# Kubeflow
All files are available in the official [kubeflow repository](https://github.com/kubeflow/manifests). The offical documentation is found at [kubeflow.org](https://www.kubeflow.org/)

## Prerequisites 
- `Kubeflow` 1.27 supports `kubernetes` up to 1.25
  - `kubelet`, `kubectl` and prefferable `kubeadm` for this setup.
  - `sudo apt remove kubelet kubectl kubeadm \ sudo apt install kubelet=1.25.10-00 kubeadm=1.25.10-00 kubectl=1.25.10-00`
  - A default `storageclass` is required
- [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/) above 5.0.0
  - Following automatically find correct version and download to your current working directory
  - `curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash`
  - Move into folder where it is coverd by `PATH`
  - `sudo mv kustomize /bin/`

## Default StoragClass
A requirement from `Kubeflow`, see [this manifest](../manifests/kubeflow/patches/storageclasses.yaml).

## Volumes
Kubeflow will create `persistentVolumeClaim`s for
- authservice
- katib
- minio
- mysql

Create [`persistentVolume`](../manifests/kubeflow/patches/persistentvolumes.yaml) to satisfy this.
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: kubeflow-<service>-pv
spec:
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: default-storage
  local:
    path: "/srv/kubeflow/<service>"
  claimRef: 
    name: <service-claim>
    namespace: kubeflow
  nodeAffinity:
      required:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
            - <node>
```
## Authservice
If the pod `authservice` cannot start due to `open /var/lib/authservice/data.db: permission denied`
You need to change the `permissions` before the container starts in the pod.

In the file: [`kubeflow/manifests/common/oidc-authservice/base/statefulset.yaml`](../manifests/kubeflow/manifests/common/oidc-authservice/base/statefulset.yaml)
Add:
```
initContainers:
- name: fix-permission
  image: busybox
  command: ['sh','-c']
  args: ['chmod -R 777 /var/lib/authservice;']
  volumeMounts:
  - name: data
    mountPath: /var/lib/authservice
```

<details>
  <summary>Full file</summary>
  
    ```
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: authservice
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: authservice
      serviceName: authservice
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
          labels:
            app: authservice
        spec:
          initContainers:
          - name: fix-permission
            image: busybox
            command: ['sh','-c']
            args: ['chmod -R 777 /var/lib/authservice;']
            volumeMounts:
            - name: data
              mountPath: /var/lib/authservice
          serviceAccountName: authservice
          containers:
          - name: authservice
            image: gcr.io/arrikto/kubeflow/oidc-authservice:e236439
            imagePullPolicy: Always
            ports:
            - name: http-api
              containerPort: 8080
            envFrom:
              - secretRef:
                  name: oidc-authservice-client
              - configMapRef:
                  name: oidc-authservice-parameters
            volumeMounts:
              - name: data
                mountPath: /var/lib/authservice
            readinessProbe:
                httpGet:
                  path: /
                  port: 8081
          securityContext:
            fsGroup: 111
          volumes:
            - name: data
              persistentVolumeClaim:
                  claimName: authservice-pvc
    ```
  
</details>
This will spin up a lightweight container to change the permission for the folder.

## Expose service
Default settings for the web-interface is thought `ClusterIP` mode, however to make it accessable for machines outside the cluster the `istio-ingressgateway` service will be changed to `NodePort` and a port `31000` will be specified. Also the `kubeflow-gateway` will be changed to redirect `http` calls to `https` and open upp the `https`-port. 

A self signing certificate manager is also setup due to `https`. See [patches](../manifests/kubeflow/patches) for more details.


Kubeflow will be access via the browser at `https://<node-local-ip>:31000`.

## Start up

This oneline will install the default `Kubeflow` with all packages found in the repository. Make sure to `cd` into the repo-folder or change `example` to match the path.
```
while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```
However, there are few more steps to make sure everything is started and ready before we run this, therefore use the [start-kubeflow.sh](../scripts/start-kubeflow.sh) script



