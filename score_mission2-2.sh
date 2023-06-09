#!/bin/bash

mutatingwebhookyamls=$(ls | grep -E "mutatingwebhook_[0-9]+\.yaml")
log_dir="logs_mission2-2"
result_path="result_mission2-2.txt"

###############################################################################
# Function
###############################################################################

initialize_answer_env() {
  kubectl apply -f "$1"
  kubectl run mynginx --image nginx--restart Never
  sleep 20
}

is_pass() {
  kubectl get pods --show-labels > $1
  local count=$(grep -c "mutated=true" $1)
  if [[ count -eq 1 ]]
  then
    return 1
  else
    return 0
  fi
}

delete_answer_env() {
  kubectl delete pods mynginx
  kubectl delete -f "$1"
}

###############################################################################
# Main
###############################################################################

mkdir -p "$log_dir"
cat <<EOT > webhook.yaml
kind: Service
apiVersion: v1
metadata:
  name: webhook
  namespace: default
spec:
  selector:
    app: webhook
  ports:
  - name: https
    protocol: TCP
    port: 443
    targetPort: 5000
---
apiVersion: v1
kind: Pod
metadata:
  name: webhook
  labels:
    app: webhook
spec:
  containers:
  - name: webhook
    image: cnsedu/mutating:1.0
EOT
kubectl apply -f "webhook.yaml"
sleep 20

echo "[`date +%Y%m%d_%T`]" >> $result_path

for mutatingwebhookyaml in $mutatingwebhookyamls; do
  number=$(echo $mutatingwebhookyaml | grep -o -P '(?<=mutatingwebhook_)[0-9]+' | head -1)
  echo "[$number]"

  initialize_answer_env $mutatingwebhookyaml
  
  is_pass "$log_dir/$number.txt"
  result=$?
  if [[ $result -eq 1 ]]
  then
    echo "  - $number (O)" >> $result_path
  else
    echo "  - $number (X)" >> $result_path
  fi

  delete_answer_env $mutatingwebhookyaml
done

kubectl delete -f "webhook.yaml"
