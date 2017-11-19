# Zammad kubernetes example deployment

## Prerequisites

- Change the ingress to your needs.


## Deploy zammad

### Install on Minikube example

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
