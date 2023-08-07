namespace=monitoring
kubectl -n $namespace delete service/prometheus-service service/grafana-service
kubectl -n $namespace delete deployments.apps/prometheus deployments.apps/grafana 
kubectl -n $namespace delete pvc/prometheus-pvc pvc/grafana-pvc
#kubectl delete pv/prometheus-pv pv/grafana-pv
kubectl delete clusterrole prometheus #kube-state-metrics
kubectl delete clusterrolebindings.rbac.authorization.k8s.io prometheus #kube-state-metrics
kubectl delete namespaces $namespace
