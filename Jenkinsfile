// Variables for input
   //def DEPLOYMENT
   //def IMAGE_TAG


pipeline {
    agent any
    parameters {
        choice(name: 'DEPLOYMENT', choices: ['BLUE', 'GREEN'], description: 'Pick the environment')
        string(defaultValue: '', description: 'image version', name: 'IMAGE_TAG')

    }
    stages {
	stage('Deployment Parameters') {
	    steps {
		sh 'echo "Gather deployment parameters"'
                script {
		   
                   // Get the input
                    def userInput = input(
                            id: 'userInput', message: 'Enter deployment environment and image tag',
                            parameters: [choice(name: 'deployment', choices: ['BLUE','GREEN'].join('\n'), description: 'Please select the Environment type'),
                                         string(defaultValue: '', description: 'image version', name: 'image_tag')])
	            // Save to variables.
                   DEPLOYMENT = userInput.deployment
                   IMAGE_TAG = userInput.image_tag
		    // Print to the console
		       echo "${params.DEPLOYMENT} and ${params.IMAGE_TAG}"
		       	
                }
	    }
	}
        stage('Linting') {
            steps {
                sh 'echo "Lint HTML files"'
                sh 'tidy -q -e *.html'

		sh 'echo "Lint Dockerfile"'
		sh 'hadolint Dockerfile'
            }
        }
	stage('Build image') {
	   steps {
		sh 'echo "Building docker image with tag ${params.IMAGE_TAG}"'
		sh 'docker build -t simple-nginx:${params.IMAGE_TAG} .'
           }
        }
	stage('Push image') {
	   steps {
		sh 'echo "Pushing image to docker hub"'
		//sh 'echo "$DOCKER_PASSWORD" | docker login -u maltekreeti --password-stdin'
    		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub-credential-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
                     sh '''
		         IMAGE_ID=$(docker images --filter=reference=simple-nginx:${IMAGE_TAG} --format "{{.ID}}")
                         docker tag $IMAGE_ID maltekreeti/simple-nginx:${env.IMAGE_TAG}
		         docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
                         docker push maltekreeti/simple-nginx:${IMAGE_TAG}
                     '''
               }
	   }
	}
	stage('Deploy staging') {
	   steps {
		sh 'echo "Deploy the container in kubernetes (green)"'
		withAWS(region:'us-east-1',credentials:'aws-nginx') {
	            sh 'aws eks --region us-east-1 update-kubeconfig --name prod --kubeconfig /home/ubuntu/.kube/config'
		    sh '''
			//DEPLOYMENT=blue envsubst < service.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
			envsubst < deployment.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
		    '''
                }
	   }
	}
        stage('User input') {
           steps {
                sh 'echo "User decision to move the traffic to the new deployment"'
	        input('Do you want to proceed?')
           }
        }
        stage('Deploy production') {
           steps {
                sh 'echo "Switch the traffic to the new deployment (blue)"'
                sh 'envsubst < service.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -'
           }
        }
    }
}
