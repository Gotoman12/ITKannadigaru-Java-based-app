pipeline{
    agent any 
    tools{
        jdk 'java-17'
        maven 'Maven'
    }

    stages{
        stage('GIT_CHECKOUT'){
            steps{
                    git url:'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git',branch:'DecSecOps'
            } 
        }
        stage('compile'){
            steps{
                sh 'mvn compile'
            }
        }
        stage('test'){
            steps{
                sh 'mvn clean test'
            }
        }
        stage('package'){
            steps{
                sh 'mvn clean package'
            }
        }
    }
}