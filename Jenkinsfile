pipeline {
  agent any

  environment {
    ARM_CLIENT_ID       = credentials('f585654a-5c60-4a21-8589-77c2dccd496b').username
    ARM_CLIENT_SECRET   = credentials('f585654a-5c60-4a21-8589-77c2dccd496b').password
    ARM_SUBSCRIPTION_ID = 'c82980ca-ac33-439d-a896-7efaa573acd1'
    ARM_TENANT_ID       = 'ee6d7e1a-390c-40d0-a1c0-a8213cb8254c'
  }

  stages {
    stage('Clone Repository') {
      steps {
        git branch: 'main', url: 'https://github.com/techcloud2/nss.git'
      }
    }

    stage('Initialize Terraform') {
      steps {
        bat 'terraform init'
      }
    }

    stage('Plan Infrastructure') {
      steps {
        bat 'terraform plan -var-file="terraform.tfvars"'
      }
    }

    stage('Apply Infrastructure') {
      steps {
        input message: 'Proceed with deployment?', ok: 'Deploy'
        bat 'terraform apply -var-file="terraform.tfvars" -auto-approve'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '**/*.tfstate', fingerprint: true
    }
  }
}
