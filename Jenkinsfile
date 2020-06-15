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
		sh 'docker build -t simple-nginx:v2 .'
           }
        }
	stage('Push image') {
	   steps {
		sh 'echo "Pusing image to docker hub"'
		sh 'IMAGE_ID=$(docker images --filter=reference=simple-nginx:v2 --format "{{.ID}}")'
		//sh 'echo "$DOCKER_PASSWORD" | docker login -u maltekreeti --password-stdin'
    		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub-credential-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
                     sh '''
                     docker tag b4d46aa1d677 maltekreeti/simple-nginx:v2
                     docker push maltekreeti/simple-nginx:v2
                     '''
               }
	   }
	}
    }
}
