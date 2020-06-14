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
		sh 'cat ~/docker_hub_password.txt | docker login -u maltekreeti --password-stdin'
		sh 'docker tag $IMAGE_ID maltekreeti/simple-nginx:v2'
		sh 'docker push maltekreeti/simple-nginx:v2'
	   }
	}
    }
}