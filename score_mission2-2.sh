#!/bin/bash

mutatingwebhookyamls=$(ls | grep -E "mutatingwebhook_[0-9]+\.yaml")
log_dir="scoring_logs_mission2-2"
result_path="result_mission2-2.txt"

mkdir -p "$log_dir"
kubectl apply -f "webhook.yaml"

###############################################################################
# Function
###############################################################################

initialize_answer_env() {
  kubectl apply -f "$1"
  kubectl run mynginx--image nginx--restart Never
}

is_pass() {
  kubectl get pods --show-labels > $1
  local count=$(grep -c 'mutated=true' '$1')
  if [count -eq 1]; then
    return true
  else
    return false
  fi
}

delete_answer_env() {
  kubectl delete -f "$1"
}

###############################################################################
# Main
###############################################################################

for mutatingwebhookyaml in $mutatingwebhookyamls; do
  number=$(echo $mutatingwebhookyaml | grep -o -P '(?<=mutatingwebhook_)[0-9]+' | head -1)
  echo "[$number]"

  initialize_answer_env $mutatingwebhookyaml

  if [$( is_pass "$log_dir/$number.txt" ) = true]; then
    echo "[$number] O" >> $result_path
  else
    echo "[$number] X" >> $result_path
  fi

  delete_answer_env $mutatingwebhookyaml
done

kubectl delete -f "webhook.yaml"
