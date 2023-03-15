# Add secrets
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd
kubectl create secret docker-registry docker-registry-secret --docker-server=docker-registry:5000 --docker-username=myuser --docker-password=mypasswd

# Remove taint on control-plane
kubectl taint node eva node-role.kubernetes.io/control-plane-

# Create Persistent volume, claim, deployment and service
kubectl create -f ./registry-volume.yaml
kubectl create -f ./registry-service-deploy.yaml
