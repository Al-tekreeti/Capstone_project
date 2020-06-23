pipeline {
    agent any
    stages {
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
		sh 'docker build -t simple-nginx:v4 .'
           }
        }
	stage('Push image') {
	   steps {
		sh 'echo "Pushing image to docker hub"'
		//sh 'echo "$DOCKER_PASSWORD" | docker login -u maltekreeti --password-stdin'
    		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub-credential-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
                     sh '''
		         IMAGE_ID=$(docker images --filter=reference=simple-nginx:v4 --format "{{.ID}}")
                         docker tag $IMAGE_ID maltekreeti/simple-nginx:v4
		         docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
                         docker push maltekreeti/simple-nginx:v4
                     '''
               }
	   }
	}
	stage('Deploy image') {
	   steps {
		sh 'echo "Deploy the container in kubernetes"'
		//sh 'aws eks --region us-east-1 update-kubeconfig --name prod-blue.us-east-1.eksctl.io --kubeconfig /var/lib/jenkins/config'
		//sh 'kubectl get svc'
		withAWS(region:'us-east-1',credentials:'aws-nginx') {
	            sh 'aws eks --region us-east-1 update-kubeconfig --name prod --kubeconfig /home/ubuntu/.kube/config'
		    sh '''
			DEPLOYMENT=blue envsubst < service.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
			DEPLOYMENT=blue IMAGE_TAG=v4 envsubst < deployment.yaml | kubectl --kubeconfig /home/ubuntu/.kube/config apply -f -
		    '''
                    //sh 'kubectl get svc --kubeconfig /home/ubuntu/.kube/config'
                }
	   }
	}
    }
}
