#!/bin/bash

main() {
    # set global variable (and validate input)
    validate_cli_inputs_instantiate_vars "$@"

    local GIT_REPO="https://github.com/devopsnow-deployments/${customer_name}"
    local GIT_REV="HEAD"
    local GIT_PATH="${cluster_type}/${cluster_provider}/${cluster_region}/${cluster_name}/apps"

    ensure_argo_cli_tool "$@"
    argo_login $argo_url $argo_username $argo_password
    argo_git_repo_add $GIT_REPO $git_repo_username $git_repo_password
    if [ ! -z "$stack_name" ]; then
        argo_create_project $stack_name
    fi
    argo_create_customer_app $customer_name $GIT_REPO $GIT_REV $GIT_PATH

    exit 0
}

step_print() {
    echo ""
    echo "*************************"
    echo "*  $1"
    echo "*************************"
    echo ""
}

argo_login() {
    step_print "Attempting to switch Argo context to $1"
    echo "argocd login $1 --username $2 --password $3"
    if [ $? -ne 0 ]; then
        echo "Unable to argo login successfully."
        exit 1
    fi
}

argo_git_repo_add() {
    local git_repo=$1
    local git_user=$2
    local git_pass=$3

    step_print "Adding git repo $git_repo to Argo"
    echo "argocd repo add $git_repo --username $git_pass --password $git_pass"
    if [ $? -ne 0 ]; then
        echo "Unable to add git repo to argo successfully."
        exit 1
    fi
}

argo_create_project() {
    local stack_name=$1

    step_print "Creating Argo project $stack_name"

    echo "Found a stack name ($stack_name), used to deploy Argo apps to non-default projects..."
    echo "  creating that project."
    echo "argocd proj create $stack_name --dest \"*,*\" --src \"*\""
    if [ $? -ne 0 ]; then
        echo "Unable to create argo project successfully."
        exit 1
    fi
}

argo_create_customer_app() {
    local customer_name=$1 
    local git_repo=$2 
    local git_rev=$3
    local git_path=$4

    step_print "Creating Argo app devopsnow-remote-${customer_name}-apps"

    echo "argocd app create devopsnow-remote-${customer_name}-apps --repo $git_repo --path $git_path --revision $git_rev --dest-server https://kubernetes.default.svc --directory-recurse" 
    if [ $? -ne 0 ]; then
        echo "Unable to add argo app successfully."
        exit 1
    fi
}

# Confirm argocd CLI tool exists, otherwise install it
ensure_argo_cli_tool() {
    if ! command -v argocd; then
        echo "Trying to install argocd CLI for ${OSTYPE}..."

        ARGOCD_VERSION="v1.8.4"
        DL_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo curl -sSL -o /usr/local/bin/argocd ${DL_URL}/argocd-linux-amd64
            sudo chmod +x /usr/local/bin/argocd
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sudo curl -sSL -o /usr/local/bin/argocd ${DL_URL}/argocd-darwin-amd64
            sudo chmod +x /usr/local/bin/argocd
        else
            echo "Could not install argocd CLI for your system. Please do so manually."
            exit 1
        fi
    fi
}

validate_cli_inputs_instantiate_vars() {
    # Read all command line arguments
    for ARGUMENT in "$@"
    do

        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

        case "$KEY" in
                cluster_name)         cluster_name=${VALUE} ;;
                cluster_type)         cluster_type=${VALUE} ;;
                cluster_provider)     cluster_provider=${VALUE} ;;
                cluster_region)       cluster_region=${VALUE} ;;
                customer_name)        customer_name=${VALUE} ;;
                stack_name)           stack_name=${VALUE} ;;
                argo_url)             argo_url=${VALUE} ;;
                argo_username)        argo_username=${VALUE} ;;
                argo_password)        argo_password=${VALUE} ;;
                git_repo_username)    git_repo_username=${VALUE} ;;
                git_repo_password)    git_repo_password=${VALUE} ;;
                *)   
        esac    
    done

    # Validate that all required inputs are provided
    echo ""
    echo "Validating input arguments ..."
    if [[ -n $cluster_name ]] \
        && [[ -n $cluster_type ]] \
        && [[ -n $cluster_provider ]] \
        && [[ -n $cluster_region ]] \
        && [[ -n $customer_name ]] \
        && [[ -n $argo_url ]] \
        && [[ -n $argo_username ]] \
        && [[ -n $argo_password ]] \
        && [[ -n $git_repo_username ]] \
        && [[ -n $git_repo_password ]];
    then
        echo "All required arguments are present. Continuing ..."
    else
        echo "Not all required arguments are present. The following arguments are required: "
        echo "  cluster_name"
        echo "  cluster_tenancy"
        echo "  cluster_type"
        echo "  cluster_provider"
        echo "  cluster_region"
        echo "  customer_name"
        echo "  argo_url"
        echo "  argo_username"
        echo "  argo_password"
        echo "  git_repo_username"
        echo "  git_repo_password"
        echo ""
        echo "You can optionally pass in 'stack_name' to create an argo project. This is in case "
        echo "  Application definitions are configured to that project."
        echo ""
        echo "The git repo is generated via the customer name and the cluster properties: "
        echo "  URL  - https://github.com/devopsnow-deployments/<customer>"
        echo "  Path - <tenancy>/<type>/<provider>/<region>/<cluster>/apps"
        exit 1
    fi
}


main "$@"