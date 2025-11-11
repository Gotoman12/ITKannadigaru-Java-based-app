pipeline{
    agent any 
    tools{
        jdk 'jdk-17'
        maven 'maven'
    }
    environment {
        IMAGE_NAME= "gotoman12/itkananda:${GIT_COMMIT}"
    }
    stages{
        stage("CHECKOUT STAGE"){
            steps{
                git url: "https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git", branch: 'main'
            }
        }
        stage("compile"){
            steps{
               sh '''
                  mvn compile
            '''
            }
            
        }
         stage("packing"){
            steps{
               sh '''
                  mvn clean package
            '''
            }
            
        }
        stage("docker build"){
            steps{
               sh '''
                printenv
                  docker build -t ${IMAGE_NAME} .
            '''
            }
            
        }
        stage("docker testing"){
            steps{
               sh '''
               docker kill itkannada
               docker rm itkannada
               docker run -it -d --name itkannada -p 6001:8080 ${IMAGE_NAME}
            '''
            }
           stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
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
    }

}
