pipeline{
    agent any // decided which node to run

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    environment {
        IMAGE_NAME = "arjunckm/itkannadigaru-blogpost:${GIT_COMMIT}"
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

        stage('Compile'){
            steps{
                sh '''
                    mvn compile
                '''
            }
        }
        stage('packaging'){
            steps{
                sh '''
                    mvn clean package
                '''
            }
        }
        stage('docker-build'){
            steps{
                sh '''
                    printenv
                    docker build -t ${IMAGE_NAME} .
                '''
            }
        }
       // stage('Docker-testing'){
        //   steps{
         //       sh '''
          //          docker kill itkannadigaru-blogpost-test
            //        docker rm itkannadigaru-blogpost-test
              //      docker run -it -d --name itkannadigaru-blogpost-test -p 9000:8080 ${IMAGE_NAME}
                //'''
            //}
        //}   

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_hubcred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        // Login to Docker Hub
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }  

        stage('Push to dockerhub'){
            steps{
                sh '''
                    docker push ${IMAGE_NAME}
                '''
            }
        }
       stage("update the k8 cluster"){
         steps{
            sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
         }
       }
       stage("deploy-eks-cluster"){
        steps{
            withKubeConfig(caCertificate: '', clusterName: 'itkannadigaru-cluster', contextName: '', credentialsId: 'kube', namespace: 'javaapp', restrictKubeConfigAccess: false, serverUrl: 'https://97F921246B0C22CA12CFED42E1AFF094.gr7.us-east-1.eks.amazonaws.com') {
                sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
                sh 'kubectl apply -f deployment.yml -n ${NAMESPACE}'
        }
       }
    }
     stage("deploy-eks-cluster"){
        steps{
            withKubeConfig(caCertificate: '', clusterName: 'itkannadigaru-cluster', contextName: '', credentialsId: 'kube', namespace: 'javaapp', restrictKubeConfigAccess: false, serverUrl: 'https://97F921246B0C22CA12CFED42E1AFF094.gr7.us-east-1.eks.amazonaws.com') {
                sh "kubectl get pods -n ${NAMESPACE}"
                sh 'kubectl get svc -n ${NAMESPACE}'
        }
       }
    }
}
}
