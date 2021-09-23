# iac-aws-eks-fargate-alb-ingress# iac-aws-eks-fargate 
O objetivo desse projeto é publicar o ALB ingress em um cluster EKS com Fargate existente

# Setup do ambiente
Instale os seguintes itens em sua maquina:
1.	Instalar o awscli
2.  Instalar o eksctl
3.	Instalar o Docker
3.	Instalar o Helm

# Criando o cluster
1. Abra o prompt de comando
2. Acesse a pasta raiz do projeto
3. Rode o comando: docker build -t deploy -f devops/iac/deploy/Dockerfile .
4. Rode o comando para validar o terraform: docker run \
	-e AWS_ACCESS_KEY_ID="your_access_key" \
	-e AWS_SECRET_ACCESS_KEY="your_secret_access_key" \
	-e AWS_REGION="your_region" \
	-e ENV="dev" \
	-e ENV_VERSION="v1" \
    -e NAME="k8s-rocketseat" \
	-e CLUSTER_REGION="us-east-1" \
	deploy

# Destruindo o cluster
1. Abra o prompt de comando
2. Acesse a pasta raiz do projeto
3. Rode o comando: docker build -t destroy -f devops/iac/destroy/Dockerfile .
4. Rode o comando para validar o terraform: docker run \
	-e AWS_ACCESS_KEY_ID="your_access_key" \
	-e AWS_SECRET_ACCESS_KEY="your_secret_access_key" \
	-e AWS_REGION="your_region" \
	-e ENV="dev" \
	-e ENV_VERSION="v1" \
    -e NAME="k8s-rocketseat" \
	-e CLUSTER_REGION="us-east-1" \
	destroy