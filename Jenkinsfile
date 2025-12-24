pipeline {
    agent any

    environment {
        IMAGE_NAME = "arjunckm/fullstack:${GIT_COMMIT}"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "itkannadigaru-cluster"
        NAMESPACE = "javaapp"
    }

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    stages {
        stage('git-checkout'){
            steps{
                 git url: 'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git', branch: 'feature-1'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Build') {
            steps {
                sh "mvn package"
            }
        }

       stage("Docker-build"){
            steps{
                 sh ' docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_hubcred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }
        
        stage('Updating the Cluster') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                }
            }
        }
        
        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'itkannadigaru-cluster', contextName: '', credentialsId: 'kube', namespace: 'javaapp', restrictKubeConfigAccess: false, serverUrl: 'https://97F921246B0C22CA12CFED42E1AFF094.gr7.us-east-1.eks.amazonaws.com') {
                    sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
                    sh "kubectl apply -f deployment.yml -n ${NAMESPACE}"
                }
            }
        }

        stage('Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'itkannadigaru-cluster', contextName: '', credentialsId: 'kube', namespace: 'javaapp', restrictKubeConfigAccess: false, serverUrl: 'https://97F921246B0C22CA12CFED42E1AFF094.gr7.us-east-1.eks.amazonaws.com') {
                    sh "kubectl get pods -n microdegree"
                    sh "kubectl get svc -n microdegree"
                }
            }
        }
    }
}