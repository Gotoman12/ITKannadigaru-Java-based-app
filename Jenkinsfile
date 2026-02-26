pipeline{
    agent any

    parameters{
        choice(name: 'terraformAction',choices: ['apply','destroy'],description: 'Choose your terraform action')
    }

    environment {
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
   }
    stages{
        stage("GIT_CLONING"){
            steps{
              git url: "https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git" , branch:"iac-qa"
            }
        } 
        stage("Plan"){
            steps{
                sh '''
                    cd eks
                    terraform init
                    terraform plan -out=tfplan
                '''
            }
        }
        stage("Approval"){
            steps{
               script{
                 input message:"Do you want to proceed with the Terraform action?",
                 parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
            }
        }
        stage('Apply or Destroy'){
            steps{
                sh '''
                  cd eks
                   if [ "${terraformAction}" = "apply" ]; then
                    terraform apply tfplan
                else
                    terraform destroy -auto-approve
                fi
                '''
            }
        }
    }
}