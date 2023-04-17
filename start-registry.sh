# Remove taint on control-plane
kubectl taint node eva node-role.kubernetes.io/control-plane-

# Add storage label on eva and create namespace
kubectl label nodes eva nodetype=storage
kubectl create namespace registry

# Add secrets
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key --namespace=registry
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd --namespace=registry
kubectl create secret docker-registry docker-registry-secret --docker-server=docker-registry:5000 --docker-username=myuser --docker-password=mypasswd --namespace=registry

# Create Persistent volume, claim, deployment and service
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create -f $DIR/manifests/docker-registry
