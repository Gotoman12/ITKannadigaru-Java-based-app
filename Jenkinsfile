pipeline {
    agent any

    tools {
        jdk 'java-17'
        maven 'Maven'
    }

    stages {

        stage('GIT_CHECKOUT') {
            steps {
                git url: 'https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git',
                    branch: 'DecSecOps'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Generate JaCoCo Report') {
            steps {
                sh 'mvn jacoco:report'
            }
        }

        stage('Publish Code Coverage') {
            steps {
                jacoco(
                    execPattern: '**/target/jacoco.exec',
                    classPattern: '**/target/classes',
                    sourcePattern: '**/src/main/java',
                    inclusionPattern: '**/*.class'
                )
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
