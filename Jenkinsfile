pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: kaniko-build
  namespace: jenkins
spec:
  serviceAccountName: jenkins
  containers:
  - name: maven
    image: maven:3.9.9-amazoncorretto-21-alpine
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
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
                container('maven') {
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
                    --context=${WORKSPACE} \
                    --destination=$IMAGE_NAME:latest
                    '''
                }
            }
        }
    }
}
