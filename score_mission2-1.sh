#!/bin/bash

podyamls=$(ls | grep -E "pod_[0-9]+\.yaml")
log_dir="logs_mission2-1"
result_path="result_mission2-1.txt"

###############################################################################
# Function
###############################################################################

function initialize_answer_env {
  kubectl apply -f $1
  sleep 20 
}

function is_pass {
  kubectl logs trouble > $1
  local complete_count=$(grep -c "Mission Complete" $1)
  if [[ $complete_count -eq 1 ]]
  then
    return 1 
  else
    return 0 
  fi
}

function delete_answer_env {
  kubectl delete -f $1
}

###############################################################################
# Main
###############################################################################

mkdir -p "$log_dir"
echo "[`date +%Y%m%d_%T`]" >> $result_path

for podyaml in $podyamls; do
  number=$(echo $podyaml | grep -o -P '(?<=pod_)[0-9]+' | head -1)
  echo "[$number]"

  initialize_answer_env $podyaml

  is_pass "$log_dir/$number.txt"
  result=$?
  if [[ $result -eq 1 ]]
  then
    echo "  - $number (O)" >> $result_path
  else
    echo "  - $number (X)" >> $result_path
  fi

  delete_answer_env $podyaml
done
