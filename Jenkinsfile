pipeline{
    agent any

    tools{
        jdk 'java-17'
        maven 'maven'
    }
    
    environment{
        IMAGE_NAME = "manojkrishnappa/itblogpost:${GIT_COMMIT}"
    }

    stages{
        stage('Git-checkout'){
            steps{
                git url: 'https://github.com/ManojKRISHNAPPA/ITKannadigaru-Java-based-app.git',branch: 'dev'
            } 
        }

        stage('Compile'){
            steps{
                sh '''
                    mvn compile
                '''
            }
        }

        stage('maven build'){
            steps{
                sh '''
                    mvn clean package
                '''
            }
        }
        stage('Building-Stage'){
            steps{
                sh '''
                    printenv
                    docker build -t ${IMAGE_NAME} .
                '''
            } 
        }
        stage('Testing-Stage'){
            steps{
                sh '''
                    docker kill itkannadigaru-blog-post
                    docker rm itkannadigaru-blog-post
                    docker run -it -d --name itkannadigaru-blog-post -p 9001:8080 ${IMAGE_NAME}
                '''
            } 
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

        stage('Pushing to Docker hub'){
            steps{
                sh '''
                    docker push ${IMAGE_NAME}
                '''
            }
        }
    }

}