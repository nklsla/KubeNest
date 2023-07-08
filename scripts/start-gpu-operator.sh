# Start gpu operator in cluster. Only drivers needs to be installed at nodes.

helm install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator --set driver.enabled=false
