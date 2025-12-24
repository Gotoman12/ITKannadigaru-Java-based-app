pipeline {
    agent any

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "itkannadigaru-cluster"
        NAMESPACE = "javaapp"
        DOCKER_REPO = "arjunckm/itkannadigaru-blogpost"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git url: 'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git',
                    branch: 'feature-1'
                script {
                    env.IMAGE_TAG = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t ${DOCKER_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker_hubcred',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh 'docker push ${DOCKER_REPO}:${IMAGE_TAG}'
            }
        }

        stage('Deploy to EKS') {
            steps {
                withKubeConfig(
                    credentialsId: 'kube',
                    namespace: 'javaapp'
                ) {
                    sh '''
                    sed -i 's|replace|${DOCKER_REPO}:${IMAGE_TAG}|g' deployment.yml
                    kubectl apply -f deployment.yml -n ${NAMESPACE}
                    kubectl rollout status deployment/itkannadigaru-blogpost -n ${NAMESPACE}
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withKubeConfig(
                    credentialsId: 'kube',
                    namespace: 'javaapp'
                ) {
                    sh '''
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}
