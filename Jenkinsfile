pipeline {
    agent any

    tools {
        jdk 'java-17'
        maven 'Maven'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git',
                    branch: 'DecSecOps'
            }
        }

        stage('Build & Test with Coverage') {
            steps {
                sh 'mvn clean test'
            }
        }
    }

    post {
        always {
            junit testResults: '**/target/surefire-reports/*.xml',
                  allowEmptyResults: true
        }
    }
}
