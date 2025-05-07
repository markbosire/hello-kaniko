# Jenkins Pipeline with Kaniko on Kubernetes

This repository contains a simple Java application that is built using Jenkins and Kaniko, with Jenkins agents running in a Kubernetes (kind) cluster.

## Project Structure

```
.
├── config.json
├── Dockerfile
├── Jenkinsfile
├── kind
│   ├── jenkins-config.yaml
│   └── jenkins-token.yaml
├── pom.xml
└── src
    └── main
        └── java
            └── com
                └── example
                    └── HelloKaniko.java
```

## Prerequisites

- Docker
- kubectl
- kind (Kubernetes in Docker)
- Running Jenkins instance 

## Setup Instructions

### 1. Create a Kind Cluster for Jenkins Agents

Create a Kind cluster using the provided configuration:

```bash
# Create a new cluster with the jenkins-config.yaml replace the placeholder ip with your local ip
kind create cluster --name jenkins --config kind/jenkins-config.yaml

# Verify the cluster is running
kubectl cluster-info --context kind-jenkins
```

### 2. Configure Kubernetes for Jenkins Agents

Apply the necessary Kubernetes configurations for Jenkins agent connection:

```bash
# Create the Jenkins service account and token
kubectl apply -f kind/jenkins-token.yaml

# Verify the service account was created
kubectl get serviceaccounts -n jenkins
```

### 3. Get Kubernetes Cluster Information

Retrieve the information needed to configure Jenkins:

```bash
# Get the Kubernetes API server address
kubectl cluster-info

# Get the service account token
kubectl -n jenkins get secret $(kubectl -n jenkins get sa jenkins -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode
```

### 4. Configure Jenkins Kubernetes Cloud Plugin

1. In your existing Jenkins instance, navigate to "Manage Jenkins" > "Manage Nodes and Clouds" > "Configure Clouds"
2. Click "Add a new cloud" > "Kubernetes"
3. Configure with the following settings (based on your configuration):

- **Name**: kubernetes-kind
- **Kubernetes URL**: https://192.168.100.21:58350 (your kubernetes url)
- **Disable https certificate check**: Checked (for kind clusters)
- **Kubernetes Namespace**: jenkins
- **Credentials**: Add and select the Jenkins service account token from step 3
- **Jenkins URL**: http://192.168.100.50:8080/ (your jenkins url)
- **Pod Labels**: Key: jenkins, Value: slave
- **Connection Timeout**: 5
- **Read Timeout**: 15
- **Concurrency Limit**: 10
- **Container Cleanup Timeout**: 5

Click "Test Connection" to verify the configuration.

### 5. Create Docker Registry Configuration

Create a ConfigMap for Docker registry authentication:

```bash
# Generate the Base64 encoded auth string from your Docker credentials
echo -n "your-username:your-password" | base64
# This will output something like: eW91ci11c2VybmFtZTp5b3VyLXBhc3N3b3Jk

# Create a Docker config.json file with the generated string replace the place holder auth with the generated one
cat > config.json <<EOF
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "eW91ci11c2VybmFtZTp5b3VyLXBhc3N3b3Jk"
    }
  }
}
EOF

# Create ConfigMap
kubectl create configmap docker-config --from-file=config.json -n jenkins
```

Replace the example auth string with your actual Base64-encoded Docker registry credentials. For different registries, replace `https://index.docker.io/v1/` with your registry URL.

### 6. Run the Jenkins Pipeline

After setting up the Kubernetes cloud configuration, you can run the pipeline in one of two ways:

#### Option A: Run from SCM

1. In Jenkins, create a new "Pipeline" job
2. In the Pipeline section, select "Pipeline script from SCM"
3. Select your SCM (e.g., Git)
4. Enter your repository URL
5. Specify the branch and script path (Jenkinsfile)
6. Save and run the pipeline

#### Option B: Run Directly in Jenkins

1. In Jenkins, create a new "Pipeline" job
2. In the Pipeline section, select "Pipeline script"
3. Paste the contents of your Jenkinsfile
4. Save and run the pipeline
```

## Troubleshooting Common Issues

If you encounter issues with the pipeline:

- **Connection error to Kubernetes API**: Verify API server URL and token are correct
- **Pod creation timeout**: Check network connectivity between Jenkins and Kind cluster
- **Kaniko build failure**: Ensure Dockerfile is valid and accessible in workspace
- **Registry push failure**: Verify config.json contains valid authentication

You can check pod status and logs with:
```bash
kubectl get pods -n jenkins
kubectl logs <pod-name> -c kaniko -n jenkins
```

## Additional Resources

- [Jenkins Kubernetes Plugin Documentation](https://plugins.jenkins.io/kubernetes/)
- [Kaniko Documentation](https://github.com/GoogleContainerTools/kaniko)
- [Kind Documentation](https://kind.sigs.k8s.io/)
