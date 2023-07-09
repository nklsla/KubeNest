DIR_KUBEFLOW="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR_PATCH=$DIR_KUBEFLOW/../manifests/kubeflow/patches

# Create storage class and pv's for kubeflow services
kubectl apply -f $DIR_PATCH/cluster-objects/storageclasses.yaml
kubectl apply -f $DIR_PATCH/persistentvolumes.yaml
cd $DIR_KUBEFLOW/../manifests/kubeflow/manifests
while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 5; done
cd $DIR_KUBEFLOW

# Apply patches and create certificate for https
kubectl create -f $DIR_PATCH/istio-ingress-cert.yaml
kubectl patch -n kubeflow gateways.networking.istio.io kubeflow-gateway --patch-file $DIR_PATCH/kubeflow-gateway-patch.yaml --type merge
kubectl patch -n istio-system svc istio-ingressgateway --patch-file $DIR_PATCH/istio-service-patch.yaml --type merge

