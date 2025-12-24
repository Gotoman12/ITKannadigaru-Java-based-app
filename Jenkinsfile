pipeline{
    agent any

    tools{
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        IMAGE_NAME = "arjunckm/fullstack:${GIT_COMMIT}"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "itkannadigaru-cluster"
        NAMESPACE = "javaapp"
    }

    stages{
        stage('git-checkout'){
            steps{
                 git url: 'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git', branch: 'feature-1'
            }
        }
        stage("Compile"){
            steps{
                 sh 'mvn compile'
            }
        }
        stage("Package"){
            steps{
                 sh 'mvn clean package'
            }
        }
        stage("Docker-build"){
            steps{
                 sh ' docker build -t ${IMAGE_NAME} .'
            }
        }
        stage("Docker-Login"){
            steps{
                 script{
                    withCredentials([usernamePassword(credentialsId: 'docker_hubcred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) { 
                        // Login to Docker Hub 
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                 }
            }
        }
    }
        stage("Docker-Push"){
            steps{
                 sh 'docker push ${IMAGE_NAME}'
            }
        }
        stage("update the k8 cluster"){
            steps{
               sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}" 
            }
        }
         stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'itkannadigaru-cluster', contextName: '', credentialsId: 'kube', namespace: 'microdegree', restrictKubeConfigAccess: false, serverUrl: 'https://AB2AD8E7E396070F02E8CEC4D6A0D7E9.gr7.us-east-1.eks.amazonaws.com') {
                    sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
                    sh "kubectl apply -f deployment.yml -n ${NAMESPACE}"
                }
            }
        }
    }
}