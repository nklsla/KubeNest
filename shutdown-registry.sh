namespace=registry
kubectl -n $namespace delete service/image-registry
kubectl -n $namespace delete deployments.apps/image-registry
kubectl -n $namespace delete secret cert-secret auth-secret docker-registry-secret
kubectl -n $namespace delete pvc/docker-repo-pvc
kubectl delete pv/docker-repo-pv
kubectl delete storageclasses.storage.k8s.io/local-storage 
kubectl delete namespaces $namespace
