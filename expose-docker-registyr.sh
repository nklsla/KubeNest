kubectl get pod --namespace=default -o wide
read -p "Pod IP: " pod_ip
echo $pod_ip
export REGISTRY_NAME="docker-registry"
export REGISTRY_IP=$pod_ip
USER=root
# Add these variables to /etc/hosts to allow all nodes resolve the registry name
for x in $(kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address }'); do 
  ssh -p 33445 $USER@$x "echo '$REGISTRY_IP $REGISTRY_NAME' | tee -a /etc/hosts; 
  rm -rf /etc/docker/certs.d/$REGISTRY_NAME:5000; 
  mkdir -p /etc/docker/certs.d/$REGISTRY_NAME:5000;
  scp -P 33445 /registry/certs/tls.crt $USER@$x:/etc/docker/certs.d/$REGISTRY_NAME:5000/ca.crt";
done
