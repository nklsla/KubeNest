# Shutdown helm deployments
helm delete nfs-subdir-external-provisioner
helm delete gpu-operator -n gpu-operator

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/shutdown-monitoring.sh"
source "$DIR/shutdown-registry.sh"

