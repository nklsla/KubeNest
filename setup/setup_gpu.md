# Setup GPU support 
To utilize the GPUs of the workers the graphic drivers needs to be installed along with `CUDA` and more. Luckily `nvidia` have released multiplie ways to handle that in a `kubernetes` cluster.\
The graphic drivers, cuda and other nessecary tools are available as a container solutions. I will use a `chart` from `helm`. This will identify and enable all `gpu`s available in the cluster. A `pod`/`container` will only need to request a `gpu`.

## Nvidias GPU Operator
The GPU Operator make sure all nodes in the cluster with `gpu`s are tagged and will be providing the necessary drivers when `pods` are scheduled for `gpu` work.
Follow [this guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html) for more details.

In short, download a predefined `chart` and add it to your `helm` repo

```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
```

and deploy the chart

```
helm install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator
```
This will deploy in the `namespace` `gpu-operator`. It will take about 10 minutes to initialize and start all the pods.

When the `pods`:
- `nvidia-cuda-validator`
- `nvidia-device-plugin-validator`

are marked as `complete` the deployment is ready.

### Note on drivers
This assumes that there are no Nvidia drivers or CUDA installed on the worker nodes. If so, a flag has to be set when deploying the chart.\
However I've encoutered some issue when letting `gpu operator` install the drivers, i.e. the pod `nvidia-driver-daemonset` cannot connect to nvidia drivers. This was resolved by installinge the drivers on the host machine. Add the flag
```
--set driver.enabled=false
```
at the end of the `helm install` command

## Tensorflow in container
My GPU `GeForce 960M` is quite old and will require the `nightly` version of `tensorflow` a long with a `envionment` variable.



## Example job

```
<INSTER FROM MANIFESTS>
```
