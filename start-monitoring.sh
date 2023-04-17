DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create namespace monitoring
kubectl create -f $DIR/manifests/prometheus
#kubectl create -f $DIR/manifests/kube-state-metrics
#kubectl create -f $DIR/manifests/grafana

