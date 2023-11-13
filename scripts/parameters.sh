#!/bin/bash

# SSH port for workers
export SSH_PORT="<SSH-port>"

# IP addresses
export WORKER_NODES_IP=("192.168.1.XXX" "192.168.1.XXX")
export WORKER_NODES_USER=("SSH-user" "SSH-user")

# Software versions
export FLANNEL_VERSION="v0.21.5"

# Cluster labels
export CTLPLN_NODE="ControlPlaneNode"
export WORKER_NODE_1="WorkerNode1"
export WORKER_NODE_2="WorkerNode2"

# Docker Image Registry
export DOCKER_NODEPORT=31320
export DOCKER_CLUSTER_IP="10.106.32.26"
export DOCKER_USR="myuser" 
export DOCKER_PWD="mypasswd"
export DOCKER_CRT_PATH="/srv/registry/cert/tls.crt"
export DOCKER_KEY_PATH="/srv/registry/cert/tls.key" 
export DOCER_HTPWD_PATH="/srv/registry/auth/htpasswd"

# NFS
export NFS_PATH="/srv/nfs"
export NFS_CLUSTER_IP="10.106.177.37" # Hard coded until DNS-issue fixed

# Grafana
export GRAFANA_NODEPORT=32000

# Kubeflow
export KF_ISTIO_SVC_NODEPORT=31000
export KF_KATIB_PV_PATH="/srv/kubeflow/katib"
export KF_AUTH_PV_PATH="/srv/kubeflow/authservice"
export KF_MYSQL_PV_PATH="/srv/kubeflow/mysql"
export KF_MINIO_PV_PATH="/srv/kubeflow/minio"
export KF_NOTEBOOKS_PV_PATH="/srv/kubeflow/notebooks"

