I am creating an article explaining how Jenkins can be used to do CICD for apps that are deployed to Kubernetes.  I have created a very simple app (app.py),  a simple test (test_app.py), a Dockerfile, a Jenkinsfile, and a deployment yaml (demodeployment.yaml).  And I've tested it out on a local installation of Jenkins and Kubernetes on an Ubuntu machine.   I want you to look at these files and create an article that explains the concepts, adds comments as needed to the code, also explains things in a step by step tutorial fashion.  The target audience is infrastructure engineers who don't need to babied with super basic steps.  Keep it complex so that it is engaging to college grads and devops engineers. Here are the code files:

`app.py`
```python
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    return 'Hello Kubernetes!'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

`test_app.py`
```python
import pytest
import app 
@pytest.fixture
def client():
    app.app.config['TESTING'] = True
    with app.app.test_client() as client:
        yield client
def test_hello_world(client):
    rv = client.get('/')
    assert b'Hello Kubernetes!' in rv.data
```

`Dockerfile`
```dockerfile
FROM python:3.7-slim
WORKDIR /app
RUN pip install flask pytest
COPY . /app
EXPOSE 5000
CMD ["python", "-u", "app.py"]
```

`Jenkinsfile`
```groovy
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
```

`demodeploy.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: localhost:5001/myapp:${BUILD_NUMBER}
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
      nodePort: 30080
```