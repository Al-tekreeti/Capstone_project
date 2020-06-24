pipeline {
    agent any
    stages {
	stage('Deployment Parameters') {
	    steps {
                script {
                    sh 'echo "Gather deployment parameters"'
		   // Variables for input
                    def DEPLOYMENT
                    def IMAGE_TAG
		   
                   // Get the input
                    def userInput = input(
                            id: 'userInput', message: 'Enter deployment environment and image tag',
                            parameters: [
 				    
                                    choice(defaultValue: 'green', 
                                           name: 'deployment', 
                                           choices: ['blue','green'].join('\n'), 
                                           description: 'Please select the Environment type'),
                                    string(defaultValue: 'None',
                                            description: 'image version',
                                            name: 'image_tag')
                            ])
	            // Save to variables.
                    env.DEPLOYMENT = userInput.deployment
                    env.IMAGE_TAG = userInput.image_tag?:''
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
		sh 'echo "Building docker image"'
		sh 'docker build -t simple-nginx:${env.IMAGE_TAG} .'
           }
        }
	stage('Push image') {
	   steps {
		sh 'echo "Pushing image to docker hub"'
		//sh 'echo "$DOCKER_PASSWORD" | docker login -u maltekreeti --password-stdin'
    		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub-credential-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
                     sh '''
		         IMAGE_ID=$(docker images --filter=reference=simple-nginx:${env.IMAGE_TAG} --format "{{.ID}}")
                         docker tag $IMAGE_ID maltekreeti/simple-nginx:${env.IMAGE_TAG}
		         docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
                         docker push maltekreeti/simple-nginx:${env.IMAGE_TAG}
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
			DEPLOYMENT=${env.DEPLOYMENT} IMAGE_TAG=${env.IMAGE_TAG} envsubst < deployment.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
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
                sh 'DEPLOYMENT=${env.DEPLOYMENT} envsubst < service.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -'
           }
        }
    }
}
