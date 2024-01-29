#! /bin/bash

# Read all command line arguments
for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            cluster_name)              cluster_name=${VALUE} ;;
            namespace)    namespace=${VALUE} ;;   
            opsverse_repo_username)    opsverse_repo_username=${VALUE} ;;
            opsverse_repo_password)    opsverse_repo_password=${VALUE} ;;
            opsverse_application_sourceRepoURL)    opsverse_application_sourceRepoURL=${VALUE} ;;
#             opsverse_registry_username)    opsverse_registry_username=${VALUE} ;;
#             opsverse_registry_password)    opsverse_registry_password=${VALUE} ;;
            *)   
    esac    
done

# TODO
# print  help if needed

# Setup some derived variables
opsverse_application_sourceRepoPath="remote/$cluster_name/apps"

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
echo "Validating input arguments ..."
if [[ -n $cluster_name ]] \
    && [[ -n $namespace ]] \
    && [[ -n $opsverse_repo_username ]] \
    && [[ -n $opsverse_repo_password ]] \
    && [[ -n $opsverse_application_sourceRepoURL ]];
#    && [[ -n $opsverse_application_sourceRepoPath ]] \
#     && [[ -n $opsverse_registry_username ]] \
#     && [[ -n $opsverse_registry_password ]];
then
    echo "All required arguments are present. Continuing ..."
else
    echo "Not all required arguments are present. The following arguments are required: "
    echo "  cluster_name"
    echo "  namespace"
    echo "  opsverse_repo_username"
    echo "  opsverse_repo_password"
    echo "  opsverse_application_sourceRepoURL"
#     echo "  opsverse_registry_username"
#     echo "  opsverse_registry_password"
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
echo "Installing the bootstrap components to the namespace $namespace ..."
helm upgrade --install remote-bootstrap-now -n $namespace --create-namespace remote-bootstrap \
  --repo https://registry.devopsnow.io/chartrepo/internal \
  --username $opsverse_repo_username \
  --password $opsverse_repo_password \
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
