pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    ECR_REPO   = '222634382766.dkr.ecr.us-east-1.amazonaws.com/hello-world-app'
    CLUSTER    = 'hello-world-cluster'
    IMAGE_TAG  = "v${BUILD_NUMBER}"
    HOME                        = '/var/jenkins_home'         
    AWS_SHARED_CREDENTIALS_FILE = '/var/jenkins_home/.aws/credentials'   
    AWS_CONFIG_FILE             = '/var/jenkins_home/.aws/config'        
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }               
    }

    stage('Build image') {
      steps {
        sh 'docker build -t $ECR_REPO:$IMAGE_TAG ./app'   
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
          docker push $ECR_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh '''
          aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER
          helm upgrade --install hello-world ./helm/hello-world \
            --set image.repository=$ECR_REPO \
            --set image.tag=$IMAGE_TAG
        '''
      }
    }
  }
}