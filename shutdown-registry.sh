kubectl delete service/docker-registry
kubectl delete deployments.apps/local-img-repo
kubectl delete secret cert-secret auth-secret docker-registry-secret
kubectl delete pvc/docker-repo-pvc
kubectl delete pv/docker-repo-pv
kubectl delete storageclasses.storage.k8s.io/local-storage 

