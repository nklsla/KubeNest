# Shutdown the metrics-server
namespace=kube-system
#namespace=default
kubectl -n $namespace delete deployments.apps kube-state-metrics
kubectl -n $namespace delete svc kube-state-metrics
kubectl -n $namespace delete svc kube-state-metrics-service
kubectl -n $namespace delete serviceaccounts kube-state-metrics 
