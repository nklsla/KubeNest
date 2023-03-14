kubectl delete deployments.apps/private-repository-k8s
kubectl delete service/docker-registry
kubectl delete secret cert-secret auth-secret
#kubectl delete pvc/docker-repo-pvc
#kubectl delete pv/docker-repo-pv
