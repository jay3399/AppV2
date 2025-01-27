pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'
        DOCKER_IMAGE = "jay11233/appv2-web2"
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



        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("${env.DOCKER_REGISTRY_URL}", "${DOCKER_HUB_CREDENTIALS}") {
                        sh '''
                        export DOCKER_IMAGE=${DOCKER_IMAGE}
                        docker-compose -f docker-compose_jenkins.yml build
                        docker-compose -f docker-compose_jenkins.yml push
                        '''
                    }
                }
            }
        }




        stage('Deploy to EC2') {
            steps {
                sshagent(['ssh-credentials']) {
                    sh """
                    ssh -t -o StrictHostKeyChecking=no my-ec2 << 'EOF'
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

