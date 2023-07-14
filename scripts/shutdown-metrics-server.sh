# Shutdown the metrics-server
kubectl -n kube-system delete deployments.apps metrics-server
kubectl -n kube-system delete svc metrics-server
