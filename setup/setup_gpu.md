# Setup GPU support 
To utilize the GPUs of the workers the graphic drivers needs to be installed along with `CUDA` and more. Luckily `nvidia` have released multiplie ways to handle that in a `kubernetes` cluster.\
The graphic drivers, cuda and other nessecary tools are available as a container solutions. I will use a `chart` from `helm`. This will identify and enable all `gpu`s available in the cluster. A `pod`/`container` will only need to request a `gpu`.

## Nvidia drivers
Using the containerized drivers seemd to be problematic for some nodes, the pod `nvidia-driver-daemonset` cannot connect to nvidia drivers. This was resolved by installing the drivers on the host machine and let the `gpu-operator` take care of toolkits and cuda.
```
# Install the latest drivers (23-07-10)
sudo apt install nvidia-driver-535

# Verify
nvidia-smi
```
A reboot might be necessary

## Nvidias GPU Operator
The GPU Operator make sure all nodes in the cluster with `gpu`s are tagged and will be providing the necessary drivers when `pods` are scheduled for `gpu` work.
Follow [this guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html) for more details.

In short, download a predefined `chart` and add it to your `helm` repo

```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
```

and deploy the chart (drivers are set to false since they are already installed on worker in this case)

```
helm install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator --set driver.enabled=false
```
This will deploy in the `namespace` `gpu-operator`. It will take about 10 minutes to initialize and start all the pods.

When the `pods`:
- `nvidia-cuda-validator`
- `nvidia-device-plugin-validator`

are marked as `complete` the deployment is ready.


## Tensorflow in container
My GPU `GeForce 960M` is quite old and will require the `nightly` version of `tensorflow` a long with a `envionment` variable. This graphic card have `compute capability 5.0`, a higher version is requered for the stable versions.

## Example job

```
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gaf-data-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-storage
  resources:
    requests:
      storage: 15Gi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: training-gaf
spec:
  template:
    spec:
      volumes:
        - name: data-vol
          persistentVolumeClaim:
            claimName: gaf-data-pvc
      containers:
      - name: gaf-test-job
        image: image-registry:5000/gaf-train-nightly:latest
        env:
        - name: TF_FORCE_GPU_ALLOW_GROWTH
          value: "true"
        - name: TF_ENABLE_GPU_GARBAGE_COLLECTION
          value: "true"
        - name: "IS_CONTAINER"
          value: "true"
        - name: DATA_PATH
          value: "/data/GAF"
        #command: ["/bin/bash","-c","--"]
        command: ["sleep"]
        args: ["infinity"]
        resources:
          limits:
            nvidia.com/gpu: 1
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: data-vol
          mountPath: "/app/"
      restartPolicy: Never
      imagePullSecrets:
      - name: image-registry-secret
  backoffLimit: 2

```
