DIR_MONITOR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create namespace monitoring
kubectl create -f $DIR_MONITOR/../manifests/prometheus
kubectl create -f $DIR_MONITOR/../manifests/kube-state-metrics
kubectl create -f $DIR_MONITOR/../manifests/grafana

