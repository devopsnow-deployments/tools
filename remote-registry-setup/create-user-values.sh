#!/bin/bash

for executable in kubectl helm yq; do
  if ! command -v $executable &> /dev/null; then
    echo "$executable could not be found"
    exit
  fi
done

user_defined_vals=$(helm get values -n devopsnow remote-bootstrap-now | tail -n +2)
argo_cm_data=$(kubectl get cm argocd-cm -n devopsnow -o yaml | yq e '.data' - | awk '{print "      " $0}')

values_file=$(cat <<VALUES
argo-cd: 
  server: 
    configEnabled: true  
    config:
${argo_cm_data}
${user_defined_vals}
VALUES
)

echo "$values_file"
