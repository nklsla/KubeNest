
# Setup Container Registry
This will setup a local container registry on the master node and make it available for all nodes in the kubernetes cluster. The workflow is to develop images using docker and push them to the registry. Then apply a kubernetes-job/deployment which will tell a node to pull the images from the registry.

Will probably use docker as registry as this is what I use for development of containers.\

__TODO: How to use the registry. From machine part of cluster and outside__

## Install docker
```sudo apt install docker```

Add user to group before you do any docker commands

```
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```
If you did docker commands using `sudo` before adding user to docker group and get:
```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/images/json": dial unix /var/run/docker.sock: connect: permission denied
```
Try
```
sudo chown root:docker /var/run/docker.sock
# If above doesnt work:
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```
## Authentication for registry
Set up a TLS certificate using __openssl__ and authenticate users with __htpasswd__.
I had some issues when letting the command auto create files so I had to pre allocate them.
```
sudo mkdir /srv/registry
cd /srv/registry
sudo mkdir cert auth
sudo touch cert/tls.crt cert/tls.key

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout cert/tls.key -out cert/tls.crt -subj "/CN=docker-registry" -addext "subjectAltName = DNS:docker-registry"
```

Add user authentication to be able to use the docker registry.\
  __TODO: Change user and password __
```
sudo touch auth/htpasswd
sudo chmod 777 auth/htpasswd
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn myuser mypasswd > auth/htpasswd
sudo chmod 644 auth/htpasswd
```
Distribute the certificate, this has to be done on all nodes!
```
  sudo echo {“insecure-registries” : [“docker-registry:5000”]} > /etc/docker/daemon.json
  systemctl restart snap.docker.dockerd.service
  # systemctl restart docker 
  sudo cp /srv/regitry/cert/tls.crt /etc/docker/certs.d/docker-registry:5000/ca.crt
```
Then you need to log in once to get the basic authentication\
  local port for the host machine or inside the cluster\
  nodePort for machines outside the cluster
  
  __NOTE: Might need a reboot/log off first time__
```
# Privilege to run the service
sudo chown $USER /var/run/docker.sock
sudo cp /etc/docker/certs.d/docker-registry:5000/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart snap.docker.dockerd.service
# If not installed with snap:
# sudo systemctl restart docker

docker login docker-registry:<local port or nodePort>
# Username: myuser
# Password: mypasswd
  ```
Create secretes in kubernetes to mount the certificates and password.
```
kubectl create secret tls cert-secret --cert=/srv/registry/cert/tls.crt --key=/srv/registry/cert/tls.key
kubectl create secret generic auth-secret --from-file=/srv/registry/auth/htpasswd
```
## Expose the registry
Once the service is up and running. This will make sure nodes within the cluster can access it and machine outside should be able to access as well, to push in new code.
### Expose within the cluster
From `service` manifest: Use port fomr the `port` or `targetPort`.
### Expose outside of cluster
From `service` manifest: Use port from the `ǹodePort` setting.
