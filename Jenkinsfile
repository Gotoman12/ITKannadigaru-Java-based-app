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
            steps{
              git url: "https://github.com/Gotoman12/ITKannadigaru-Java-based-app.git" , branch:"iac-qa"
            }
        } 
        stage("Plan"){
            steps{
                sh '''
                    pwd; cd eks/; terraform init
                    pwd; cd eks/; terraform plan -out tfplan
                '''
            }
        }
        stage("Approval"){
            steps{
               scripts{
                 input message:"Do you want to proceed with the Terraform action?",
                 parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
            }
        }
        stage('Apply or Destroy'){
            steps{
                sh '''
                  cd eks
                   if [ "${TerraformAction}" = "apply" ]; then
                    terraform apply tfplan
                else
                    terraform destroy -auto-approve
                fi
                '''
            }
        }
    }
}