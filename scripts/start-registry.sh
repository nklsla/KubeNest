# Remove taint on control-plane
#kubectl taint node ${CTLPLN_NODE} node-role.kubernetes.io/control-plane-
#kubectl taint node ${CTLPLN_NODE} special=control-plane:NoSchedule


# Add storage label on eva and create namespace
kubectl label nodes eva nodetype=storage
kubectl create namespace registry

# Add secrets for deployment/registery
kubectl create secret tls cert-secret --cert="${DOCKER_CRT_PATH}" --key="${DOCKER_KEY_PATH}" --namespace=registry
kubectl create secret generic auth-secret --from-file="${DOCER_HTPWD_PATH}" --namespace=registry

# Add secret for user/pods
kubectl create secret docker-registry image-registry-secret --docker-server=image-registry:5000 --docker-username="${DOCKER_USR}" --docker-password="${DOCKER_PWD}"

# Create Persistent volume, claim, deployment and service
DIR_REGISTRY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#kubectl create -f <(envsubst <$DIR_REGISTRY/../manifests/registry)
for f in $DIR_REGISTRY/../manifests/registry/*.yaml; do kubectl create -f <(envsubst <$f); done
