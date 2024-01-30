DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set environment variables from config
source $DIR/scripts/start-cfg.sh
# Initialize workers
echo
echo
echo
echo "########################################"
echo "  CREATE JOIN-SCRIPT FOR WORKER NODES"
echo "########################################"
# Create join-command-file for workers
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo 'DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"' > $DIR/kub-join.sh
echo sudo systemctl restart crio.service >> $DIR/kub-join.sh
echo sudo tar -xf '$DIR'/cni_files.tar -C /etc/cni/ >> $DIR/kub-join.sh
echo sudo mkdir /run/systemd/resolve/ >> $DIR/kub-join.sh
echo sudo ln -sf /etc/resolv.conf /run/systemd/resolve/ >> $DIR/kub-join.sh
echo sudo kubeadm reset -f --cri-socket=unix:///var/run/crio/crio.sock >> $DIR/kub-join.sh 
echo -n "sudo " >> $DIR/kub-join.sh
join=$(kubeadm token create --print-join-command)
echo ${join:0:13}--cri-socket=unix:///var/run/crio/crio.sock ${join:13} >> $DIR/kub-join.sh

# Tar net.d files 
sudo tar -C /etc/cni -cvf $DIR/cni_files.tar net.d

# Send files to worker nodes
for idx in "${!WORKER_NODES_IP[@]}"
do

  while true; do
      
  ping -c3 ${WORKER_NODES_IP[$idx]} 1>/dev/null 2>/dev/null
  SUCCESS=$?

  if [ $SUCCESS -eq 0 ]
  then
      
      echo "########################"
      echo "   SUCCESFULLY PINGED "
      echo
      echo ">HOST: ${WORKER_NODES_USER[$idx]}"
      echo ">IP:   ${WORKER_NODES_IP[$idx]}"
      echo "########################"

      # Send files to workers
      echo "Sending files.."
      scp -P $SSH_PORT $DIR/kub-join.sh $DIR/cni_files.tar ${WORKER_NODES_USER[$idx]}@${WORKER_NODES_IP[$idx]}:/tmp/

      # Execute the join-file 
      echo "Run join-script on worker: $REMOTE_HOST"
      ssh -t -p $SSH_PORT  ${WORKER_NODES_USER[$idx]}@${WORKER_NODES_IP[$idx]} "source /tmp/kub-join.sh"
      break
  fi

  read -p "Cannot reach ${WORKER_NODES_IP[$idx]}, retry? (y/n)" yn
      case $yn in
          [Yy]* ) continue;;
          [Nn]* ) break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
  echo
  echo
  echo
  
done

