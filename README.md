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
ssh-add <(curl https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant)
ansible-playbook -i infrastructure/inventory/ansible_inventory.yml --become infrastructure/haproxy/balancer.yml
```  
  
_Issue:_ The IP address of haproxy instance is not added to the kubernetes certificate, and kubectl doesn't connect to the cluster with TLS error. To avoid this reconfigure connection with the command

```bash
kubectl config set-cluster cluster.local --server=https://<haproxy>:6443/ --insecure-skip-tls-verify=true
```

## Applications

- [GCP microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)  
  applications source code is included
- [microservices-demo](https://github.com/microservices-demo/microservices-demo)  
  monitoring and load testing are included

## CI/CD  

to be developed based on GitLab.