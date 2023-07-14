#!/bin/bash

# SSH port for workers
export SSH_PORT=#####

# IP addresses
export WORKER_NODES_IP=("192.168.x.x" "192.168.x.x")
export WORKER_NODES_USER=("username" "username")

# Software versions
export FLANNEL_VERSION="v0.21.5"

# Cluster labels
export CTLPLN_NODE="node-name"
export WORKER_NODE_1="node-name"
export WORKER_NODE_2="node-name"

# Docker Image Registry
export DOCKER_NODEPORT=#####
export DOCKER_CLUSTER_IP="10.106.32.26"
export DOCKER_USR="myuser" 
export DOCKER_PWD="mypasswd"
export DOCKER_CRT_PATH="/path/to/cert/tls.crt"
export DOCKER_KEY_PATH="/path/to/cert/tls.key" 
export DOCER_HTPWD_PATH="/path/to/auth/htpasswd"

# NFS
export NFS_PATH="/path/to/nfs/folder"
export NFS_CLUSTER_IP="10.106.177.37" # Hard coded until DNS-issue fixed

# Grafana
export GRAFANA_NODEPORT=#####

# Kubeflow
export KF_ISTIO_SVC_NODEPORT=#####
export KF_KATIB_PV_PATH="/path/to/kubeflow/katib"
export KF_AUTH_PV_PATH="/path/to/ubeflow/authservice"
export KF_MYSQL_PV_PATH="/path/to/kubeflow/mysql"
export KF_MINIO_PV_PATH="/path/to/kubeflow/minio"
export KF_NOTEBOOKS_PV_PATH="/path/to/kubeflow/notebooks"

