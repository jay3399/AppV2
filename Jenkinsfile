pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'
//         SSH_CREDENTIALS = 'ssh-credentials'
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


        stage('Install Docker Buildx') {
                    steps {
                        sh '''
                        mkdir -p ~/.docker/cli-plugins/
                        curl -SL https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
                        chmod +x ~/.docker/cli-plugins/docker-buildx
                        docker buildx version
                        '''
                    }
                }


        stage('Setup Docker Buildx') {
                    steps {
                       sh 'docker buildx create --name mybuilder --use'
                       sh 'docker buildx inspect --bootstrap'
                    }
        }

        stage('Build Docker Image') {
                    steps {
                         script {
                             docker.withRegistry("${env.DOCKER_REGISTRY_URL}", "${DOCKER_HUB_CREDENTIALS}") {
                             sh "docker buildx build --platform linux/amd64,linux/arm64 -t ${DOCKER_IMAGE} . --push"  }
                         }
                    }
        }



        stage('Deploy to EC2') {
            steps {
                sshagent(['ssh-credentials']) {
                    sh """
                    ssh -t -o StrictHostKeyChecking=no ec2-user@ec2-3-141-196-190.us-east-2.compute.amazonaws.com << 'EOF'
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
//         aa
            cleanWs()
        }
    }
}

