FROM ubuntu:20.10

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get -y install python3 && \
    apt install -y python3-pip && \
    pip3 install awscli --upgrade && \
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    apt-get -y install helm && \
    apt-get -y install git

WORKDIR /app

COPY . .

CMD chmod +x deploy-ingress.sh && \
    ./deploy-ingress.sh