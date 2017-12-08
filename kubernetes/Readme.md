# Zammad kubernetes example deployment

This is a proof of concept of a Kubernetes deployment, which should be considered
beta and not ready for production.

## Prerequisites

- Kubernetes 1.8.x Cluster with at least 1 node, 2 CPUs and 4 GB of RAM
- Change the ingress to your needs


## Deploy Zammad

### Install on Minikube

* Install kubectl
  * https://kubernetes.io/docs/tasks/tools/install-kubectl/
* Install Minkube
  * https://github.com/kubernetes/minikube
* minikube start --memory=4096 --cpus=2
* minikube addons enable ingress
* echo "$(minikube ip) zammad.example.com" | sudo tee -a /etc/hosts
* kubectl apply -f .
* minikube dashboard
  * switch to namespace "zammad"
  * open "Overview" and wait until all pods are green
* access zammad on:
  * http://zammad.example.com


### Install on Google Kubernetes Engine
* connect to cluster via gcloud command
* kubectl proxy
* kubectl apply -f .
* open dashboard in browser
  * http://127.0.0.1:8001/ui
* if everything is green add backends / ingress rules to create external endpoint


## If you want to help to improve the Kuberntes deployments here are some todos:
* add cpu & mem limits
* add rolling upgrade strategy to deployments
* add RBAC
