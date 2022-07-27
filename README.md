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
- Choose one of environment directories inside of `envs` folder. Point `$labenv` variable to it  
  ```bash
  labenv="dev"      # for local virtualbox installation
  labenv="prod1"    # for yandex cloud installation based on EC2 instances
  labenv="prod2"    # managed k8s in yandex
  ```
- Setup inventory file `./envs/$labenv/hosts.yml`
Define required host names and their parameters

2. Build the instances  
  
```bash  
cd ./envs/$labenv/terraform
terraform init  
terraform plan  
terraform apply
```  
This will create virtualbox machines defined in the `hosts.yml` and generate `./envs/$labenv/ansible/ansible_inventory.yml` according to `kubespray` specification.

3. Provision Kubernetes cluster  
  
```bash
# we use default vagrantbox key from the repository for accessing the machines
ssh-add <(curl https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant)
# for cloud provisioned machines
ssh-add "~/ya_key.pub"
git clone https://github.com/kubernetes-sigs/kubespray.git /tmp/kubespray
ansible-playbook -i ./envs/$labenv/ansible/ansible_inventory.yml --become /tmp/kubespray/cluster.yml
```

4. Provision haproxy (if required)

```bash
# install custom role (actually it's geerlingguy.haproxy) but for the moment
# the main version doesn't support multiple frontend-packends and we have to use development version
ansible-galaxy install -r ./modules/ansible/haproxy/requrements.yml
ansible-playbook -i ./envs/$labenv/ansible/ansible_inventory.yml --become ./modules/ansible/haproxy/balancer.yml
```  
  
_Issue:_ The IP address of haproxy instance is not added to the kubernetes certificate, and kubectl doesn't connect to the cluster because of TLS error. 
_Workaround:_ reconfigure connection with the command

```bash
ssh <master_node> sudo cat /root/.kube/config>~/.kube/config
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
git clone https://github.com/microservices-demo/microservices-demo /tmp/microservices-demo
kubectl apply -f /tmp/microservices-demo/deploy/kubernetes/complete-demo.yaml
# ingresses for sock-shop.example address
kubectl apply -f apps/sock-shop

echo "<balancerIP> sock-shop.example" | sudo tee -a /etc/hosts
```
After installation the project should be accessible as http://sock-shop.example/

default load test
```
docker run --net=host weaveworksdemos/load-test -h sock-shop.example -r 100 -c 2
```


### GCP microservices-demo

see documentation for the project

## CI/CD  

to be developed based on GitLab.