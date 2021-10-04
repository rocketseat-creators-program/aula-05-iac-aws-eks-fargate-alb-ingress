check_sucessful() {
  if [ $? != 0 ];
  then
    echo "Error Execution"
    exit 1
  fi
}

validate_envs() {

  if [ -z "$ENV" ] || [ -z "$ENV_VERSION" ] || [ -z "$CLUSTER_REGION" ] || [ -z "$NAME" ]; 
  then
    echo "The parameters ENV, ENV_VERSION, REGION and NAME are mandatory"
    exit 1
  fi
}

get_account() {
    AWS_ACCOUNT=$(aws sts get-caller-identity --output text |awk '{print $1}')
        check_sucessful
}

solve_local_variables () {
    CLUSTER_NAME="${NAME}-${ENV}-${ENV_VERSION}"
    POLICY_NAME="ALBIngressControllerIAMPolicy-${CLUSTER_NAME}"
    POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT}:policy/${POLICY_NAME}"
    SERVICE_ACCOUNT_NAME="alb-ingress-controller"
}

get_kube_config() {
    aws eks update-kubeconfig --name $CLUSTER_NAME --region ${CLUSTER_REGION}
        check_sucessful
}

destroy_service_account() {

    eksctl delete iamserviceaccount \
        --cluster=${CLUSTER_NAME} \
        --region ${CLUSTER_REGION} \
        --namespace=kube-system \
        --name=aws-load-balancer-controller

    sleep 1m
}

destroy_policy() {
    aws iam delete-policy --policy-arn ${POLICY_ARN}
}

destroy_ingress() {

    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
        check_sucessful

    helm repo add eks https://aws.github.io/eks-charts
        check_sucessful

    helm repo update
        check_sucessful

    helm delete aws-load-balancer-controller \
        -n kube-system
        check_sucessful
}

validate_envs
    check_sucessful

get_account
    check_sucessful

solve_local_variables
    check_sucessful

get_kube_config
    check_sucessful

destroy_ingress
    check_sucessful

destroy_service_account
    check_sucessful

destroy_policy
    check_sucessful