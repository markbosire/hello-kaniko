pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: kaniko-build
  namespace: jenkins  // Using jenkins namespace
spec:
  serviceAccountName: jenkins  // Using jenkins service account
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker/
  volumes:
  - name: docker-config
    configMap:
      name: docker-config
"""
        }
    }
    environment {
        IMAGE_NAME = "markbosire/hello-kaniko"
    }
    stages {
        stage('Build Java App') {
            steps {
                container('kaniko') {
                    sh 'mvn clean package'
                }
            }
        }
        stage('Build and Push with Kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                    --dockerfile=Dockerfile \
                    --context=/home/spidey/projects/hello-kaniko \
                    --destination=$IMAGE_NAME:latest
                    '''
                }
            }
        }
    }
}
