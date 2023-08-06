# Shutdown all services
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for f in "$DIR"/scripts/shutdown*;do
  if ! echo "$f" | grep -qE '(nfs|metrics)';then
    echo ""
    echo "###### Running $(basename $f)  ######"
    source $f
  fi
done

echo ""
echo "###### Shutdown Storage  ######"
for f in "$DIR"/scripts/shutdown*;do
  if echo "$f" | grep -qE 'nfs';then
    echo ""
    echo "###### Running $(basename $f)  ######"
    source $f
  fi
done

# Shutdown metrics server
scource $DIR/scripts/shutdown-metrics-server.sh

# Remove storage classes
kubectl delete storageclasses.storage.k8s.io default-storage nfs-client

