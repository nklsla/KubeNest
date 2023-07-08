# Define variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create namespace storage
kubectl label nodes eva nodetype=storage
kubectl create -f $DIR/../manifests/cluster-objects/nfs.yaml

