# Start the metrics server
# Used for "kubectl top nodes"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create -f <(envsubst <$DIR/../manifests/cluster-objects/metric-server.yaml)
