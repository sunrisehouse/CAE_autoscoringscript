#!/bin/bash

podyamls=$(ls | grep -E "pod_[0-9]+\.yaml")
log_dir="scoring_logs_mission2-1"
result_path="result_mission2-1.txt"

mkdir -p "$log_dir"

###############################################################################
# Function
###############################################################################

initialize_answer_env() {
  kubectl apply -f $1
  sleep 100
}

is_pass() {
  kubectl logs trouble > $1
  local complete_count=$(grep -c 'Mission Complete!!' "$1")
  if [$complete_count = 1 ]]; then
    return true
  else
    return false
  fi
}

delete_answer_env() {
  kubectl delete -f $1
}

###############################################################################
# Main
###############################################################################

for podyaml in $podyamls; do
  number=$(echo $podyaml | grep -o -P '(?<=pod_)[0-9]+' | head -1)
  echo "[$number]"

  initialize_answer_env $podyaml

  if [$( is_pass "$log_dir/$number.txt" )]; then
    echo "[$number] O" >> $result_path
  else
    echo "[$number] X" >> $result_path
  fi

  delete_answer_env $podyaml
done
