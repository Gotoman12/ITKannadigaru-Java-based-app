pipeline{
    agent any

    parameters{
        choice(name: 'terraformAction',choices: ['apply','destroy'],description: 'Choose your terraform action')
    }

    environment{
        AWS_ACCESS_KEY_ID = credentialsId("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY_ID = credentialsId("AWS_SECRET_ACCESS_KEY")
    }

    stages{
        stage("GIT_CLONING"){
            git url: "https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git" , branch:"iac-qa"
        } 
        stage(""){
            steps{
                sh '''
                    terraform init
                    terraform plan -out tfplan
                    terraform show -no-color tfplan > tfplan.txt
                '''
            }
        }
    }
}