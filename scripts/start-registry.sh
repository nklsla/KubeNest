# Add storage label on eva and create namespace
#kubectl label nodes $CTLPLN_NODE nodetype=storage
kubectl create namespace registry

# Add secrets for deployment/registery
# Certficates does not seems to work properly, they still have to be mounted at node
kubectl create secret tls cert-secret --cert="${DOCKER_CRT_PATH}" --key="${DOCKER_KEY_PATH}" --namespace=registry
kubectl create secret generic auth-secret --from-file="${DOCKER_HTPWD_PATH}" --namespace=registry

# Add secret for pods in their namespaces
#kubectl create secret docker-registry image-registry-secret --docker-server=image-registry:5000 --docker-username="${DOCKER_USR}" --docker-password="${DOCKER_PWD}"
kubectl create secret docker-registry image-registry-secret --docker-server=image-registry:5000 --docker-username="${DOCKER_USR}" --docker-password="${DOCKER_PWD}" --namespace=kf-dev

# Create Deployment and Service
DIR_REGISTRY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for f in $DIR_REGISTRY/../manifests/registry/*.yaml; do kubectl create -f <(envsubst <$f); done
