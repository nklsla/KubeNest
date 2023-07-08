#!/bin/bash

# Define the list of namespaces
namespaces=("kubeflow" "knative-serving" "knative-eventing" "cert-manager" "istio-system" "auth" "kubeflow-user-example-com")

# Loop through the namespaces
for namespace in "${namespaces[@]}"
do
  # Delete everthing within the current namespace
  kubectl -n "$namespace" delete all --all
  kubectl -n "$namespace" delete pvc --all
done
kubectl delete pv kubeflow-authservice-pv kubeflow-katib-pv kubeflow-mysql-pv kubeflow-minio-pv
