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
		sh 'sudo su'
		sh 'docker build -t simple-nginx:v2 .'
		sh 'exit'
           }
        }
    }
}
