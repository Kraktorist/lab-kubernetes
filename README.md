# Kubernetes lab

## Purpose

The purpose of this lab is 
- to deploy cloud resources
- to deploy k8s infrastructure
- to deploy a microservice application
- to perform routine CI/CD operations

## Infrastructure

Cloud (TODO) or local (virtualbox) platform deployed with terraform. 
Kubernetes deployed with kubespray.

### Local virtualbox installation

0. Requirements  
- virtualbox
- terraform
- git
- ansible
- ansible roles for haproxy
- docker

1. Inventory  
Setup inventory file [hosts.yml](infrastructure/inventory/hosts.yml)
Define required host names and their parameters

2. Build the instances  
  
```bash  
cd virtualbox  
terraform init  
terraform plan  
```  
This will create virtualbox machines defined in the `hosts.yml` and generate `infrastructure/inventory/ansible_inventory.yml` according to `kubespray` requirements

3. Provision Kubernetes cluster  
  
```bash
# we use default vagrantbox key from the repository for accessing the machines
ssh-add <(curl https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant)
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray 
ansible-playbook -i infrastructure/inventory/ansible_inventory.yml --become kubespray/cluster.yml
```

4. Provision haproxy (if required)

```bash
# install custom role (actually it's geerlingguy.haproxy) but for the moment
# the main version doesn't support multiple frontend-packends and we have to use development version
ansible-galaxy install -r infrastructure/haproxy/requrements.yml
ssh-add <(curl https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant)
ansible-playbook -i infrastructure/inventory/ansible_inventory.yml --become infrastructure/haproxy/balancer.yml
```  
  
_Issue:_ The IP address of haproxy instance is not added to the kubernetes certificate, and kubectl doesn't connect to the cluster with TLS error. To avoid this reconfigure connection with the command

```bash
kubectl config set-cluster cluster.local --server=https://<haproxy>:6443/ --insecure-skip-tls-verify=true
```

## Applications

There are two basic cases planning
- [GCP microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)  
  this can be used for working on CI/CD process as it has source code included 
- [microservices-demo/microservices-demo](https://github.com/microservices-demo/microservices-demo)  
  this can be used for working on monitoring and load testing as it has some tools included

### microservices-demo/microservices-demo

see documentation for the project

```bash
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
kubectl apply -f deploy/kubernetes/complete-demo.yaml
```
default load test
```
docker run --net=host weaveworksdemos/load-test -h k8s_node:nodeport -r 100 -c 2
```


### GCP microservices-demo

see documentation for the project

## CI/CD  

to be developed based on GitLab.