pipeline{
    agent any 
    tools{
        jdk 'jdk-17'
        maven 'maven'
    }
    environment {
        IMAGE_NAME= "Gotoman12/ITKannada:${GIT_COMMIT}"
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
                  docker build -t ${IMAGE_NAME}
            '''
            }
            
        }
    }
   
}