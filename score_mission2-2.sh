#!/bin/bash

podyamls=$(ls | grep -E "pod_[0-9]+\.yaml")
log_dir="scoring_logs_mission2-1"
result_path="result_mission2-1.txt"

# 결과를 저장할 폴더 생성
mkdir -p "$log_dir"

for podyaml in $podyamls; do
  number=$(echo $podyaml | grep -o -P '(?<=pod_)[0-9]+' | head -1)
  echo "[$number]"

  kubectl apply -f "$podyaml"
  kubectl logs trouble > "$log_dir/$number.txt"
  kubectl delete -f "$podyaml"

  complete_count=$(grep -c 'Mission Complete!!' "$log_dir/$number.txt")

  if [[ $complete_count -eq 1 ]]; then
    echo "[$number] O" >> $result_path
  else
    echo "[$number] X" >> $result_path
  fi
done
