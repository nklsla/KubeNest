
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

### Set up login details
I had some issues when letting the command auto create files so I had to pre allocate them.
```
sudo mkdir /srv/registry
cd /srv/registry
sudo mkdir cert auth
sudo touch cert/tls.crt cert/tls.key

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout cert/tls.key -out cert/tls.crt -subj "/CN=image-registry" -addext "subjectAltName = DNS:image-registry"
```

Add user authentication to be able to use the docker registry.\
Change `USERNAME` and `PASSWORD` to something suitable.
```
sudo touch auth/htpasswd
sudo chmod 777 auth/htpasswd
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn USERNAME PASSWORD > auth/htpasswd
sudo chmod 644 auth/htpasswd
```
The login details will be saved in `auth/htpasswd` in format `USERNAME:<hashed password>`.

### Distribute the certificate
Run these commands to enable the docker service to authenticate via certificate.
```
  #sudo echo {“insecure-registries” : [“image-registry:5000”]} > /etc/docker/daemon.json
  systemctl restart snap.docker.dockerd.service
  # systemctl restart docker 
  sudo cp /srv/registry/cert/tls.crt /etc/docker/certs.d/image-registry:5000/ca.crt
```
__This has to be done on all nodes!??? Maybe only on outside machines. Secretes might solve this authentication?__\
You'll have to send them over to the machines that are outside the cluster in order to authenticate. and

- __NODES__
- Add DNS-resolve
- Copy certificates to /etc/docker/certs.d/image-reg:port/ca.crt
- Create secretes for auth

- __MACHINES OUTSIDE CLUSTER__
- Insecure registry?
- Install docker
- DNS-resolve node IP
- restart docker
- login


### Setup basic authentication
You need to log in at least once to get the basic authentication on machines that will be using the registry before they can pull/push any images.
- use `local port` for the host machine or inside the cluster
- use `nodePort` for machines outside the cluster

But first you need to the `DNS` in `/etc/hosts` to connect using the `DNS`
```
127.0.0.1 localhost
127.0.1.1 <user>

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Add below
# For nodes in the cluster the service-IP can be used
10.106.32.26 image-registry
# For machines outside of cluster use any of the node ip's
# 192.168.1.80 image-registry
```
 
```
# Privilege to run the service
sudo chown $USER /var/run/docker.sock
sudo cp /etc/docker/certs.d/image-registry:5000/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart snap.docker.dockerd.service
# If not installed with snap:
# sudo systemctl restart docker

docker login image-registry:<local port or nodePort>
# Username: USERNAME
# Password: PASSWORD
  ```
 __NOTE: Might need a reboot/log out/in first time__

### Create secretes 
For automatic authentication within the cluster, secrets are needed.
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
