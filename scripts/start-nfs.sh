# Define variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create namespace storage
kubectl label nodes ${CTLPLN_NODE} nodetype=storage
kubectl create -f <(envsubst <$DIR/../manifests/cluster-objects/nfs.yaml)

