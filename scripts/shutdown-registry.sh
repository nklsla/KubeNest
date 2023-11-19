namespace=registry
kubectl -n $namespace delete service/image-registry
kubectl -n $namespace delete deployments.apps/image-registry
kubectl -n $namespace delete secret cert-secret auth-secret 
#kubectl -n $namespace delete pvc/docker-repo-pvc
kubectl delete secret image-registry-secret
#kubectl delete pv/docker-repo-pv
kubectl delete namespaces $namespace
