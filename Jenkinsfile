pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        SSH_CREDENTIALS = credentials('ssh-credentials')
        DOCKER_IMAGE = "josw90/appv2-web:latest"
        DOCKER_REGISTRY_URL = "https://index.docker.io/v1/"
        GITHUB_CREDENTIALS = credentials('github-credentials')

    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jay3399/AppV2.git' , credentialsId: "${env.GITHUB_CREDENTIALS}"
            }

        }

        stage('Build') {
            steps {
                sh './gradlew build'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE}", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("${env.DOCKER_REGISTRY_URL}", 'DOCKER_HUB_CREDENTIALS') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['SSH_CREDENTIALS']) {
                    sh """
                    ssh -i /Users/jay/Downloads/web.pem ec2-user@ec2-3-141-196-190.us-east-2.compute.amazonaws.com << EOF
                    cd /home/ec2-user
                    docker-compose -f /home/ec2-user/docker-compose.yml down
                    docker-compose -f /home/ec2-user/docker-compose.yml pull web
                    docker-compose -f /home/ec2-user/docker-compose.yml up -d
                    EOF
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
