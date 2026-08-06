FROM jenkins/jenkins:lts-jdk17
USER root

# Build tools Jenkins needs: docker CLI, git, unzip, curl, and the AWS CLI
RUN apt-get update && apt-get install -y docker.io git curl unzip && rm -rf /var/lib/apt/lists/*
#                                        ^ hint: docker.io

# AWS CLI v2
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip \
    && unzip -q awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" \
    && install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl

# helm
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# stay as root so Jenkins can use the mounted Docker socket (simplification for this challenge)