for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            CLUSTER_NAME)              CLUSTER_NAME=${VALUE} ;;
            NAMESPACE)    NAMESPACE=${VALUE} ;;     
            *)   
    esac    


done

echo "CLUSTER_NAME = $CLUSTER_NAME"
echo "NAMESPACE = $NAMESPACE"
