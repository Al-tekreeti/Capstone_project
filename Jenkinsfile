
pipeline {
    agent any
    stages {
	stage('Deployment Parameters') {
	    steps {
		sh 'echo "Gather deployment parameters"'
                script {
		   
                   // Get the input
                    env.DEPLOYMENT = input(
                            message: 'Enter deployment environment and image tag',
                           parameters: [choice(name: 'deployment', choices: ['blue','green'].join('\n'), description: 'Please select the Environment type')])
		    // Print to the console
		       echo "${env.DEPLOYMENT}"
		       	
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
               sh ' echo "Building docker image with tag ${BUILD_NUMBER}"'
	       sh 'docker build -t simple-nginx:${BUILD_NUMBER} .'
           }
        }
	stage('Push image') {
	   steps {
		sh 'echo "Pushing image to docker hub"'
		//sh 'echo "$DOCKER_PASSWORD" | docker login -u maltekreeti --password-stdin'
    		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub-credential-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
                     sh '''
		         IMAGE_ID=$(docker images --filter=reference=simple-nginx:${BUILD_NUMBER} --format "{{.ID}}")
                         docker tag $IMAGE_ID maltekreeti/simple-nginx:${BUILD_NUMBER}
		         docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
                         docker push maltekreeti/simple-nginx:${BUILD_NUMBER}
                     '''
               }
	   }
	}
	stage('Deploy staging') {
	   steps {
		sh 'echo "Deploy the container in kubernetes (green)"'
		withAWS(region:'us-east-1',credentials:'aws-nginx') {
	            sh 'aws eks --region us-east-1 update-kubeconfig --name prod --kubeconfig /home/ubuntu/.kube/config'
		    sh """
			#!/usr/bin/env bash
			DEPLOYMENT=${env.DEPLOYMENT} IMAGE_TAG=${BUILD_NUMBER} envsubst < deployment.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
		    """
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
                sh """
	           #!/usr/bin/env bash
         	   DEPLOYMENT=${env.DEPLOYMENT}  envsubst < service.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
		"""
           }
        }
    }
}
