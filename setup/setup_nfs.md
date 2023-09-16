# Setup Network Filesystem Service
A NFS server is hosted in kubernetes and accessed by other services like nfs-subdir-external-provisioner, image registry and prometheus.
<!--toc-->
  * [NFS server](#nfs-server)
    + [Troubleshoot](#troubleshoot)
  * [Dynamic provisioners](#dynamic-provisioners)
    + [Install nfs-subdir-external-provisioner via Helm](#install-nfs-subdir-external-provisioner-via-helm)
  * [Open firewall ports](#open-firewall-ports)

## NFS server
This is the simplest option to run a nfs-server. It creates a pods and a service that maps to a folder on the node running the pod. Then exposed as a service for other pods to mount and access.<br>
See [nfs.yaml](/manifests/cluster-objects/nfs.yaml)

### Troubleshoot
There is a known issue when Kubernetes resolving volumes DNS-names. The workaround is to use static `clusterIP`. Following is an example on how to mount a volume to the nfs-serve:
```
 volumes:
 - name: repo-vol
        nfs:
          #server: nfs-service.storage.svc.cluster.local
          server: 10.106.177.37 # Hard coded until DNS-issue fixed
          path: "/registry"
          readOnly: falseL
```


## Dynamic provisioners
Setup NFS subdir external provisioner, using helm makes it really simple, [see package repo for more](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner). <br> Using this make life much easier when working with kubeflow. Every time you create a new notebook this will automatically create a volume (unless you choose an existing volume).

<!-- ### Install and create directories -->
<!-- ``` -->
<!-- sudo apt install nfs-kernel-server -y -->
<!---->
<!-- sudo mkdir /srv/nfs -->
<!-- sudo chown nobody:nogroup /srv/nfs -->
<!-- sudo chmod g+rwxs /srv/nfs/ -->
<!-- ``` -->
<!-- ### Share the directories -->

<!-- sudo exportfs -av -->
<!-- ``` -->
<!-- Set mountd and allow access -->
<!---->
<!-- ``` -->
<!-- echo -e "mountd\t\t6666/tcp" | sudo tee -a /etc/services -->
<!-- echo -e "mountd\t\t6666/udp" | sudo tee -a /etc/services -->
<!---->
<!-- ``` -->
<!---->
<!-- ### Restart NFS -->
<!-- ``` -->
<!-- sudo systemctl restart nfs-kernel-server -->
<!-- /sbin/showmount -e localhost -->
<!-- ``` -->
<!-- should output -->
<!-- ``` -->
<!-- Export list for localhost: -->
<!-- /srv/nfs 192.168.1.0/24 -->
<!-- ``` -->

<!-- ### Install NFS client on worker cluster nodes -->
<!-- SSH into each node and install the client -->
<!-- ``` -->
<!-- sudo apt update -->
<!-- sudo apt install nfs-common -y -->
<!-- ``` -->
<!-- Check connection  -->
<!-- ``` -->
<!-- # Use the NFS servers ip -->
<!-- /sbin/showmount -e 192.168.1.80  -->
<!-- ``` -->
<!-- should output -->
<!-- ``` -->
<!-- Export list for 192.168.1.80: -->
<!-- /srv/nfs 192.168.1.0/24 -->
<!-- ``` -->

<!-- ### Install Helm -->
<!---->
<!-- ``` -->
<!-- curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null -->
<!-- sudo apt-get install apt-transport-https --yes -->
<!-- echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list -->
<!-- sudo apt-get update -->
<!-- sudo apt-get install helm -->
<!-- ``` -->

### Install nfs-subdir-external-provisioner via Helm 
Installs `nfs-subdir-external-provisioner` and use `helm` to install/start a `Chart` for NFS.
This will create a `storageClass` for kubernetes that will handle creation, deletion and archival of the volume. It will create a deployment as well.
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
```
Start up: 
```
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
--set nfs.server=${NFS_CLUSTER_IP} \
--set nfs.path=/subdir-ext \
--set storageClass.onDelete=true
```

<!-- ### Create a PersistentVolumeClaim for NFS -->
<!-- This claim can be used for `pods`. -->
<!-- ``` -->
<!-- apiVersion: v1 -->
<!-- kind: PersistentVolumeClaim -->
<!-- metadata: -->
<!-- name: nfs-pvc -->
<!-- spec: -->
<!--   accessModes: -->
<!--     - ReadWriteMany -->
<!--   storageClassName: nfs-client -->
<!--   resources: -->
<!--     requests: -->
<!--       storage: 3Gi -->
<!---->
<!-- ``` -->
## Open firewall ports
Open ports on the node that host the services
```
sudo ufw allow 111/tcp
sudo ufw allow 2049/tcp
sudo ufw allow 6666/tcp
```
