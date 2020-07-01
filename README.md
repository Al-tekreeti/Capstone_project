## Project Summary
In this project, a CICD pipeline using Jenkins is developed to demonstrate the automation of the blue-green deployment strategy of a web application. The Jenkins server is hosted in an EC2 instance provided by the AWS cloud plateform. The web application is a Hello-World plain html file hosted by an NGINX server. The app is first containerized using Docker and then deployed in a Kubernetes cluster provisioned by the AWS Elastic Kubernetes Service (EKS). A separate stage in the pipeline is dedicated to guaranttee the quality of the html file and docker image using linting services.

## Usage
To use the code, you need first to provision a kubernetes cluster in AWS cloud. The easiest way to do that is by using the eksctl tool:

<code> eksctl create cluster --name prod --version 1.16 --region us-east-1 --nodegroup-name standard-workers --node-type t2.medium --nodes 4 --nodes-min 2 --nodes-max 4 --managed</code>

If the command is successful, a cluster with 4 nodes of type `t2.medium` is provisioned in the `us-east-1` region. The configuration of the cluster is available as a `config` file in the following directory:

<code>$HOME/.kube/config</code>

After installing jenkins, docker, and their dependencies in the EC2 machine, the following configurations need to be managed. Since jenkins would invoke docker non-interactively to build and deploy docker containers, jenkins as a user should be added to the docker group. To tag and push containers to docker hub, the login credentials need to be created in jenkins server. To let jenkins utilize `kubectl` to manage the cluster, jenkins should be authorized to access the `kubeconfig` file. In addition, jenkins should have to be configured properly to access AWS services. For more details, please consult <a href="https://www.jenkins.io/" class="mw-redirect" title="Jenkins site">Jenkins site</a> and <a href="https://aws.amazon.com/eks/" class="mw-redirect" title="AWS EKS site">AWS EKS site</a>.
