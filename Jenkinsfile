pipeline {
    agent any

    environment {
        COST_THRESHOLD = "200"
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        INFRACOST_API_KEY = credentials('infracost-api-key')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                terraform init
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan -out=tfplan
                '''
            }
        }

        stage('Cost Estimation (Infracost)') {
            steps {
                sh '''
                infracost breakdown --path=tfplan --format=json --out-file=infracost.json
                infracost diff --path=tfplan
                '''
            }
        }

        stage('Budget Guardrail Check') {
            steps {
                sh '''
                COST=$(jq '.totalMonthlyCost | tonumber' infracost.json)

                echo "Estimated Monthly Cost: $COST"

                if (( $(echo "$COST > $COST_THRESHOLD" | bc -l) )); then
                    echo "Budget exceeded! Cost is $COST (limit: $COST_THRESHOLD)"
                    exit 1
                else
                    echo "Cost within budget"
                fi
                '''
            }
        }

        stage('Tag Validation') {
            steps {
                sh '''  
                echo "Checking resource tags..."

                if ! grep -q "Environment" *.tf; then
                    echo "Missing Environment tag"
                    exit 1
                fi

                if ! grep -q "Owner" *.tf; then
                    echo "Missing Owner tag"
                    exit 1
                fi

                if ! grep -q "CostCenter" *.tf; then
                    echo "Missing CostCenter tag"
                    exit 1
                fi

                echo "Required tags present"
                '''
            }
        }

    }

    post {
        success {
            echo "Infrastructure cost validation passed"
        }
        failure {
            echo "Pipeline failed due to cost or policy violation"
        }
    }
}