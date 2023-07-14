# Shutdown GPU-operator via helm
helm delete gpu-operator -n gpu-operator
kubectl delete ns gpu-operator

