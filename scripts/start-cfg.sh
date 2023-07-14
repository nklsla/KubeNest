# Run config to set all environment variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config.sh

# Print for feedback
echo "#####################"
echo " Cluster environment "
echo " variables applied   "
echo "#####################"

cat $DIR/../config-cluster.sh | grep export | awk '{$1="";print $0}'

echo "#####################"
