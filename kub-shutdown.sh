nodes=$(kubectl get nodes -o name)
for node in ${nodes[@]}

do

    echo "==== Drain $node ===="
    kubectl drain --ignore-daemonsets $node
  

    #ssh $node sudo shutdown -h 1

done

