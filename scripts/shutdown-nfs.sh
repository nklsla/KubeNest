# Shutdown NFS service
kubectl delete -n storage all --all
kubectl delete ns storage
