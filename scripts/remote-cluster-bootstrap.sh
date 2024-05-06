#! /bin/bash

# Read all command line arguments
for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            cluster_provider)          cluster_provider=${VALUE} ;;
            cluster_region)          cluster_region=${VALUE} ;;
            cluster_type)              cluster_type=${VALUE} ;;
            cluster_name)              cluster_name=${VALUE} ;;
            namespace)    namespace=${VALUE} ;;   
            opsverse_repo_username)    opsverse_repo_username=${VALUE} ;;
            opsverse_repo_password)    opsverse_repo_password=${VALUE} ;;
            opsverse_application_sourceRepoURL)    opsverse_application_sourceRepoURL=${VALUE} ;;
            chart_registry_hostname)       chart_registry_hostname=${VALUE} ;;
            opsverse_registry_username)    opsverse_registry_username=${VALUE} ;;
            opsverse_registry_password)    opsverse_registry_password=${VALUE} ;;
            *)   
    esac    
done

# TODO
# print  help if needed

# Setup some derived variables
opsverse_application_sourceRepoPath="$cluster_type/$cluster_provider/$cluster_region/$cluster_name/apps"

# # Testing
# echo "cluster_name = $cluster_name"
# echo "namespace = $namespace"
# echo "opsverse_repo_username = $opsverse_repo_username"
# echo "opsverse_repo_password = $opsverse_repo_password"
# echo "opsverse_application_sourceRepoURL = $opsverse_application_sourceRepoURL"
# echo "opsverse_application_sourceRepoPath = $opsverse_application_sourceRepoPath"
# echo "opsverse_registry_username = $opsverse_registry_username"
# echo "opsverse_registry_password = $opsverse_registry_password"

# Validate that all required inputs are provided
echo ""
echo $cluster_name
echo $namespace
echo $cluster_type
echo $cluster_provider
echo $cluster_region
echo $opsverse_repo_username
echo $opsverse_repo_password
echo $opsverse_application_sourceRepoURL
echo $chart_registry_username
echo $chart_registry_password
echo $chart_registry_hostname
echo "Validating input arguments ..."
if [[ -n $cluster_name ]] \
    && [[ -n $namespace ]] \
    && [[ -n $cluster_type ]] \
    && [[ -n $cluster_provider ]] \
    && [[ -n $cluster_region ]] \
    && [[ -n $opsverse_repo_username ]] \
    && [[ -n $opsverse_repo_password ]] \
    && [[ -n $opsverse_application_sourceRepoURL ]] \
    && [[ -n $chart_registry_username ]] \
    && [[ -n $chart_registry_password ]] \
    && [[ -n $chart_registry_hostname ]];
    #    && [[ -n $opsverse_application_sourceRepoPath ]] \
then
    echo "All required arguments are present. Continuing ..."
else
    echo "Not all required arguments are present. The following arguments are required: "
    echo "  cluster_name"
    echo "  cluster_type"
    echo "  cluster_provider"
    echo "  cluster_region"
    echo "  namespace"
    echo "  opsverse_repo_username"
    echo "  opsverse_repo_password"
    echo "  opsverse_application_sourceRepoURL"
    echo "  chart_registry_hostname"
    echo "  chart_registry_username"
    echo "  chart_registry_password"
    exit 1
fi

# Validate if kubectl and helm are available
command -v "kubectl" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "kubectl is not found. Please check if it is installed."
    echo "Exiting ..."
    exit 1
fi

command -v "helm" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "helm is not found. Please check if it is installed."
    echo "Exiting ..."    
    exit 1
fi

echo ""
echo "Installing ArgoCD CRD"
kubectl apply -f https://raw.githubusercontent.com/devopsnow-deployments/tools/main/scripts/application-crd.yaml
echo "Installing the bootstrap components to the namespace $namespace ..."
helm upgrade --install remote-bootstrap-now -n $namespace --create-namespace remote-bootstrap -f ./values-override.yaml\
  --repo $chart_registry_hostname \
  --username $chart_registry_username \
  --password $chart_registry_password \
  --set devopsnow.repo.username=$opsverse_repo_username \
  --set devopsnow.repo.password=$opsverse_repo_password \
  --set devopsnow.application.sourceRepoURL=$opsverse_application_sourceRepoURL \
  --set devopsnow.application.sourceRepoPath=$opsverse_application_sourceRepoPath

echo ""
echo "Waiting for sealed-secrets component to create the key pair ..."
sleep 60

echo "Please send the following public key (base64 encoded) back to OpsVerse..."
echo ""
echo `kubectl get secret -n ${namespace} -l 'sealedsecrets.bitnami.com/sealed-secrets-key=active' -o jsonpath='{.items[].data.tls\.crt}'`
