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
        stage('Generate JaCoCo Report') {
            steps {
                sh '''
                mvn clean verify
                mvn jacoco:report
                '''
            }
        }
        stage('Publish Code Coverage') {
            steps {
                sh '''
                jacoco execPattern: '**/target/jacoco.exec',
                       classPattern: '**/target/classes',
                       sourcePattern: '**/src/main/java',
                       inclusionPattern: '**/*.class'
                       '''
            }
        }
        post{
            always {
                junit ""
            }
        }
    }
}