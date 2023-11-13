# Run config to set all environment variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if file exsists
FILE="$DIR/../configs/config.sh"
if [ ! -f $FILE ]; then
    echo "configs/config-cluster.sh not found"
    echo "fallback to ./parameters.sh"
    FILE="$DIR/parameters.sh"
    exit 1
fi
source FILE

# Print for feedback
echo "#####################"
echo " Cluster environment "
echo " variables applied   "
echo "#####################"

cat $FILE | grep export | awk '{$1="";print $0}'

echo "#####################"
