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
This might not be nessecary if NFS-storage will be used..

## Authservice
If the pod `authservice` cannot start due to `open /var/lib/authservice/data.db: permission denied`
You need to change the `permissions` before the container starts in the pod.

In the file: `manifests/kubeflow/manifests/common/oidc-authservice/base/statefulset.yaml`
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
This will spin up a lightweight container to change the permission for the folder.

## Expose service
Default settings for the web-interface is thought `ClusterIP` mode, however to make it accessable for machines outside the cluster 

## Start up

This oneline will install the default `Kubeflow` with all packages found in the repository. Make sure to `cd` into the repo-folder or change `example` to match the path.
```
while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```
However, there are few more steps to make sure everything is started and ready before we run this, therefore use the [start-kubeflow.sh](../scripts/start-kubeflow.sh) script



