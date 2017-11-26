# Zammad kubernetes example deployment

This is a proof of concept of a Kubernetes deployment, which should be considered
beta and not ready for production.

## Prerequisites

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
* kubectl apply -f .



## If you want to help to improve the Kuberntes deployments here are some todos:
* fix the nfs mount from entrypoint, which is currently used because of:
  * https://github.com/kubernetes/kubernetes/issues/8735
  * otherwise you have to manually:
    * kubectl apply -f 00_namespace.yaml -f 80_svc.yaml
    * kubectl --namespace=zammad describe services zammad-nfs
      * use the NFS server IP to update
        * 40_deployment_zammad.yaml
        * 41_deployment_nginx.yaml
    * kubectl apply -f 10_pvc.yaml -f 40_deployment_zammad.yaml -f 41_deployment_nginx.yaml -f 42_deployment_memcached.yaml -f 43_deployment_postgesql.yaml -f 44_deployment_elasticsearch.yaml -f 45_deployment_nfs.yaml -f 90_ingress.yaml
* create config map for nginx
* create a zammad helm chart
* document steps to use existing helm charts for elasticsearch, postgresql and so on
* add cpu & mem limits
* add rolling upgrade strategy to deployments
