# Setup Private Docker Image Registry
How to setup a local/private image registry and make it available for all nodes in the `kubernetes` cluster and machines outside of cluster. The reason for hosting a private image registry is that a docker registry is simpler to use in comparison to the `crio`-registry, in my experience. As it does not support pull/push by it self. It's possible using `podman` for that but at the time I realised that I had already made up my mind.

<!-- toc -->

- [Install docker](#install-docker)
- [Start registry in cluster](#start-registry-in-cluster)
- [Create authentication for registry](#create-authentication-for-registry)
  * [Login details](#login-details)
  * [Auth secret](#auth-secret)
- [Setup nodes](#setup-nodes)
  * [Resolve DNS](#resolve-dns)
  * [Distribute the certificate](#distribute-the-certificate)
  * [Example job](#example-job)
- [Setup connection for external machines](#setup-connection-for-external-machines)
  * [Insecure-registry](#insecure-registry)
  * [Basic authentication](#basic-authentication)
- [Usage](#usage)

<!-- tocstop --> 

## Install docker
A normal install of docker is needed for some steps, this could be removed once it's all setup.

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

## Start registry in cluster
Run the startup script [`scripts/start-registry.sh`](../scripts/start-registry.sh).
This will pull and start the docker image registry

## Create authentication for registry
Set up a TLS certificate using __openssl__ and authenticate users with __htpasswd__.

### Login details
To avoid some issues while letting the command auto create files, preallocate them.
```
sudo mkdir /srv/registry
cd /srv/registry
sudo mkdir cert auth
sudo touch cert/tls.crt cert/tls.key

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout cert/tls.key -out cert/tls.crt -subj "/CN=image-registry" -addext "subjectAltName = DNS:image-registry"
```

Add user authentication to be able to login to the docker registry.\
Change `USERNAME` and `PASSWORD` to something suitable.
```
sudo touch auth/htpasswd
sudo chmod 777 auth/htpasswd
docker run --rm --entrypoint htpasswd registry:2.7.0 -Bbn USERNAME PASSWORD > auth/htpasswd
sudo chmod 644 auth/htpasswd
```
The login details will be saved in `auth/htpasswd` in format `USERNAME:<hashed password>`.

### Auth secret
Setup login details as `secret` within kubernetes. This step can be skipped if [`start-registry.sh`](../scripts/start-registry.sh) is run.
```
kubectl create secret docker-registry image-registry-secret --docker-server=image-registry:5000 --docker-username=USERNAME --docker-password=PASSWORD
```

## Setup nodes
This have to be done to all nodes to access the registry (including the registry's host node).

### Resolve DNS
To resolve the `DNS`-calls add following in `/etc/hosts`.
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
# For machines outside of cluster, use any of the nodes ip's.
# Your development machine for an example
# 192.168.1.80 image-registry
```

You can find the registry-IP once it is up and running unless you have it specified (recommended) by running
```
kubectl get svc -n registry -o wide
```

### Distribute the certificate
Currently certificates in `kubernetes secretes` does not work with `docker` so these have to be added on the nodes. Here is how you can do it manually:
Run these commands to enable the docker service to authenticate via certificate.
```
# From the nodes/machine that the certificates where created on:
# Send certificate over ssh using scp
scp -P <SSH-port> /srv/registry/cert/tls.crt <user>@<ip>:/tmp/

# create directory
sudo mkdir -p /etc/docker/certs.d/image-registry:5000

# move certificate (and rename, not sure if necessary) 
sudo mv /tmp/tls.crt /etc/docker/certs.d/image-registry:5000/ca.crt
```

### Example job 
This requies that the image `test-job-img` is present and functional in the registery. See [Usage](#usage) below.
```
apiVersion: batch/v1
kind: Job
metadata:
  name: test-job
spec:
  template:
    spec:
      nodeSelector:
        cpu: "true"
      containers:
      - name: test-job-img
        image: image-registry:5000/test-job-img
        ports:
        - containerPort: 5000
        restartPolicy: Never
        imagePullSecrets:
        - name: image-registry-secret
        backoffLimit: 4
```

## Setup connection for external machines
A `docker` [install is required](#install-docker).\
The `DNS` [has to be resolved](#resolve-dns), use the node-IP this time.

### Insecure-registry
The registry has to be added as an insecure-registry. __Note: This might expose a security flaw for sensitive data__

```
sudo echo {“insecure-registries” : [“image-registry:5000”]} > /etc/docker/daemon.json

# If installed via snap
systemctl restart snap.docker.dockerd.service
# If installed via apt
# systemctl restart docker

# Copy 
sudo cp /srv/registry/cert/tls.crt /etc/docker/certs.d/image-registry:5000/ca.crt
```

### Basic authentication
You need to log in at least once to get the basic authentication on machines that will be using the registry before they can pull/push any images.
- use `local port` for the host machine or inside the cluster
 
```
# Privilege to run the service
sudo chown $USER /var/run/docker.sock
sudo cp /etc/docker/certs.d/image-registry:5000/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart snap.docker.dockerd.service
# If not installed with snap:
# sudo systemctl restart docker

docker login image-registry:<nodePort>
# Username: USERNAME
# Password: PASSWORD
  ```
 __NOTE: Might need a reboot/log out/in first time__

## Usage
A brief explanation of how to push from an external machine. Needed for [test-job](#example-job).\
Once it is pushed, `pods` can access it when creating instances.

```
# List current images in registry
docker images

# Create image from dockerfile with tag (-t), the tagname is necessary for pushing it.
docker build -t image-registry:<nodePort>/image-name <path/to/Dockerfile>

# Push to local/private registry
docker image push image-registry:<nodePort>/image-name 
```
