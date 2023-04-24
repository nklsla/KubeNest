# Remove taint on control-plane
kubectl taint node eva node-role.kubernetes.io/control-plane-

# Add storage label on eva and create namespace
kubectl label nodes eva nodetype=storage
kubectl create namespace registry

# Add secrets for deployment/registery
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key --namespace=registry
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd --namespace=registry

# Add secret for user/pods
kubectl create secret docker-registry image-registry-secret --docker-server=image-registry:5000 --docker-username=myuser --docker-password=mypasswd 

# Create Persistent volume, claim, deployment and service
DIR_REGISTRY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kubectl create -f $DIR_REGISTRY/../manifests/registry
