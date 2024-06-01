pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials'
//         SSH_CREDENTIALS = 'ssh-credentials'
        DOCKER_IMAGE = "jay11233/appv2-web"
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



        stage('Setup Docker Buildx') {
                    steps {
                        sh 'docker buildx create --use'
                        sh 'docker buildx inspect --bootstrap'
                    }
        }

        stage('Build Docker Image') {
                    steps {
                        script {
                            dockerImage = sh(script: """
                                docker buildx build --platform linux/amd64,linux/arm64 \
                                -t ${DOCKER_IMAGE} . --push
                            """, returnStdout: true).trim()
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

