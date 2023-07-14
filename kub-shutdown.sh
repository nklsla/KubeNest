# Shutdown helm deployments
#helm delete nfs-subdir-external-provisioner
#helm delete gpu-operator -n gpu-operator

# Shutdown monitoring and docker registry
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo "$DIR"/scripts/shutdown*
for f in "$DIR"/scripts/shutdown*;do
source $f
done

# Remove storage classes
#kubectl delete storageclasses.storage.k8s.io local-storage nfs-client

