pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t localhost:5001/myapp:${BUILD_NUMBER} .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm localhost:5001/myapp:${BUILD_NUMBER} python -m pytest -v test_app.py'
            }
        }
        stage('Push') {
            steps {
                sh 'docker push localhost:5001/myapp:${BUILD_NUMBER}'
            }
        }
        stage('Deploy') {
            steps {
                // sh 'kubectl apply -f demodeploy.yaml'
                // sh 'envsubst < demodeploy.yaml | kubectl apply -f -'
                // sh 'sed "s/\${BUILD_NUMBER}/$BUILD_NUMBER/g" demodeploy.yaml | kubectl apply -f -'
                sh('sed "s,\\${BUILD_NUMBER},' + env.BUILD_NUMBER + ',g" demodeploy.yaml | kubectl apply -f -')
            }
        }
    }
}