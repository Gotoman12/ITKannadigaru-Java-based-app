pipeline{
    agent any 
    tools{
        jdk 'java-17'
        maven 'Maven'
    }

    environment{
        IMAGE_NAME = "arjunckm/javaproject:${GIT_COMMIT}"
    }
    stages{
        stage('GIT_CHECKOUT'){
            steps{
                    git url:'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git',branch:'main'
            } 
        }
        stage('compile'){
            steps{
                sh 'mvn compile'
            }
        }
        stage('package'){
            steps{
                sh 'mvn clean package'
            }
        }
        stage('docker-build'){
            steps{
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }
          stage('docker-test'){
            steps{
                sh 'docker run -it -d --name javaproject-test -p 9000:8080 $(IMAGE_NAME)'
            }
        }
    }
}