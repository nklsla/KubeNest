DIR_MONITOR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create namespace monitoring
for f in $DIR_MONITOR/../manifests/prometheus/*.yaml; do kubectl create -f <(envsubst <$f); done
for f in $DIR_MONITOR/../manifests/kube-state-metrics/*.yaml; do kubectl create -f <(envsubst <$f); done
for f in $DIR_MONITOR/../manifests/grafana/*.yaml; do kubectl create -f <(envsubst <$f); done
