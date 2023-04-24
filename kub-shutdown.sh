# Shutdown helm deployments
helm delete nfs-subdir-external-provisioner
helm delete gpu-operator -n gpu-operator

# Shutdown monitoring and docker registry
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/scripts/shutdown-monitoring.sh"
source "$DIR/scripts/shutdown-registry.sh"

