pipeline {
    agent any

    stages {
        stage('Setup Environment') {
            steps {
                withCredentials([azureServicePrincipal('f585654a-5c60-4a21-8589-77c2dccd496b')]) {
                    script {
                        env.ARM_CLIENT_ID = "${env.AZURE_CLIENT_ID}"
                        env.ARM_CLIENT_SECRET = "${env.AZURE_CLIENT_SECRET}"
                        env.ARM_TENANT_ID = "${env.AZURE_TENANT_ID}"
                        env.ARM_SUBSCRIPTION_ID = 'c82980ca-ac33-439d-a896-7efaa573acd1' // Replace with actual subscription ID
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -auto-approve'
            }
        }
    }
}
