pipeline{
    agent any

    environment{
        IMAGE_NAME = "drinkapp"
        IMAGE_TAG = "dev"
        CLUSTERNAME = "drink-cluster"
        NAMESPACE = "foo"
        FINALIAMGE =  "arjunckm/${IMAGE_NAME}:${IMAGE_TAG}"
        AWS_REGION = "us-east-1"
    }

    tools{
        jdk 'java-17'
        maven 'maven'
    }

    stages{
        stage("GIT-CLONING"){
            steps{
               git url :"https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git",branch: "main"
            }
        }
        stage("Build"){
            steps{
             sh 'mvn compile'
            }
        }
        stage("Package"){
            steps{
             sh 'mvn clean package'
            }
        }
        stage("Docker Build"){
           steps{
              sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
           }
        }
        stage("Docker Login"){
           steps{
             script{
                withCredentials([usernamePassword(credentialsId:"DOCKER_CRED",usernameVariable:"DOCKER_USER",passwordVariable:"DOCKER_PASS")]){
                     sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
             }
           }
        }
        stage("Docker TAG"){
           steps{
            sh 'docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FINALIAMGE}'
           }
        }
        stage("Docker PUSH"){
           steps{
            sh 'docker push ${FINALIAMGE}'
           }
        }
        stage("K8s update"){
           steps{
            sh 'aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}'
           }
        }
        stage("Deploy K8s"){
            steps{
                script{
                    withKubeConfig(
                         caCertificate: '',
                    clusterName: '${CLUSTERNAME}',
                    contextName: '',
                    credentialsId: 'kube',
                    namespace: '${NAMESPACE}',
                    restrictKubeConfigAccess: false,
                    serverUrl: 'https://B8E6BC948B3311CCA4C6FB401E20EF84.gr7.us-east-1.eks.amazonaws.com'
                )
                    {
                        sh '''
                            sed -i "s|replace|${FINALIAMGE}|g' deployment.yaml
                            kubectl apply -f deployment.yaml -n ${NAMESPACE} --timeout=600s
                        '''
                    }
                }
            }
            post{
                always{
                    sh 'kubectl rollout status deploy/drink-app -n ${NAMESPACE}' 
                }
                success{
                    sh 'Deployed the application in eks and pipeline : pass'
                }
                failure{
                    sh 'kubectl rollout undo deploy/drink-app -n ${NAMESPACE}'
                }
            }
        }
          stage("Deploy K8s"){
            steps{
                script{
                    withKubeConfig(
                         caCertificate: '',
                    clusterName: '${CLUSTERNAME}',
                    contextName: '',
                    credentialsId: 'kube',
                    namespace: '${NAMESPACE}',
                    restrictKubeConfigAccess: false,
                    serverUrl: ''
                )
                    {
                        sh '''
                            kubectl get pods -n ${NAMESPACE}
                            kubectl get svc -n ${NAMESPACE}
                        '''
                    }
                }
            }
        }
    }
}