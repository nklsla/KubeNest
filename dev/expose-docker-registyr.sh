#kubectl get pod --namespace=default -o wide
#read -p "Pod IP: " pod_ip
#echo $pod_i
pod_ip="10.106.32.26"
export REGISTRY_NAME="docker-registry"
export REGISTRY_IP=$pod_ip
USER=nkls
# Add these variables to /etc/hosts to allow all nodes resolve the registry name
for x in $(kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address }'); do 
  #ssh -t -p 33445 $USER@$x "echo '$REGISTRY_IP $REGISTRY_NAME' | sudo tee -a /etc/hosts; 
  #sudo rm -rf /etc/docker/certs.d/$REGISTRY_NAME:5000; 
  #sudo mkdir -p /etc/docker/certs.d/$REGISTRY_NAME:5000;"
  sudo scp -P 33445 /srv/registry/cert/tls.crt $USER@$x:/etc/docker/certs.d/$REGISTRY_NAME:5000/ca.crt
done
