#!/bin/bash
echo "Shutdown namespaces stuck in 'Terminating' by force it to finilize"
echo "Usage: ./shutdown-namespace.sh <namespace-to-terminate>"

unset NS_TERM

if [ $# -eq 0 ];
then
  echo "$0: Missing arguments"
elif [ $1 == "all" ];
then
  NS_TERM=($(kubectl get ns | grep Terminating | awk '{print $1}'))
else
  NS_TERM=($@)
fi

echo "Removing: ${NS_TERM[@]}"

for NS in "${NS_TERM[@]}"; do
  kubectl get namespace "${NS}" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/"${NS}"/finalize -f - | 1> /dev/null;
  echo "Removed namespace: ${NS}"
done
