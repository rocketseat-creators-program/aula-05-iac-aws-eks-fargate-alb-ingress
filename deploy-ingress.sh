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

get_kube_config() {
    aws eks update-kubeconfig --name $CLUSTER_NAME --region ${CLUSTER_REGION}
        check_sucessful
}

get_vpc() {

    VPC_ID=$(
            aws ec2 describe-vpcs \
                --region ${CLUSTER_REGION} \
                --filters Name=tag:product,Values=network \
                    Name=tag:environment/${ENV},Values=1 \
                    Name=tag:environmentVersion/${ENV_VERSION},Values=1 \
                    Name=tag:type/application,Values=1 \
                --query 'Vpcs[*].[VpcId]' \
                --output text
        )

}

solve_local_variables () {
    CLUSTER_NAME="${NAME}-${ENV}-${ENV_VERSION}"
    POLICY_NAME="ALBIngressControllerIAMPolicy-${CLUSTER_NAME}"
    POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT}:policy/${POLICY_NAME}"
    SERVICE_ACCOUNT_NAME="alb-ingress-controller"
}

create_policy() {
    aws iam create-policy \
        --policy-name ${POLICY_NAME} \
        --policy-document file://policy.json
}

create_service_account() {

    eksctl create iamserviceaccount \
        --cluster=${CLUSTER_NAME} \
        --region ${CLUSTER_REGION} \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --attach-policy-arn=${POLICY_ARN} \
        --override-existing-serviceaccounts \
        --approve
}

deploy_ingress() {

    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
        check_sucessful

    helm repo add eks https://aws.github.io/eks-charts
        check_sucessful

    helm repo update
        check_sucessful

    helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
        --set region=${CLUSTER_REGION} \
        --set vpcId=${VPC_ID} \
        --set clusterName=${CLUSTER_NAME} \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller \
        -n kube-system
        check_sucessful
}

validate_envs
    check_sucessful

get_account
    check_sucessful

solve_local_variables
    check_sucessful

get_vpc
    check_sucessful

create_policy
    check_sucessful

create_service_account
    check_sucessful

get_kube_config
    check_sucessful

deploy_ingress
    check_sucessful