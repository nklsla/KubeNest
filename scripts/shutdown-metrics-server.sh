# Shutdown the metrics-server
namespace=kube-system
kubectl -n $namespace delete deployments.apps metrics-server
kubectl -n $namespace delete svc metrics-server
kubectl -n $namespace delete serviceaccounts kube-state-metrics 
