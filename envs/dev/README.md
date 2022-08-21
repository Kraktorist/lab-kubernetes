## VirtualBox environment

### Prerequisites

- virtualbox
- terraform
- git
- ansible
- kubectl
- jq

Most of the installation steps are described in the [Makefile](Makefile). All you need is to run them one by one.

### Hosts Installation

1. Define hosts.yml. The file must contain at least three virtual machines:
   - kubernetes master
   - gitlab
   - nexus  
Inventory for kubernetes must fit with `kubespray` inventory tree.
Other hosts are optional. There were some commented blocks for multihost `kubernetes` cluster and balancers on `haproxy`
2. Run `make install-hosts`. This will create required hosts as well as ansible inventory for them.
3. Run `make show-hosts` to show hosts information

### Kubernetes Cluster Installation

It's based on kubespray project. 
1. Redefine if it's needed [group_vars](ansible/group_vars)
2. Copy [known vagrant private key](https://github.com/hashicorp/vagrant/blob/main/keys/vagrant) to your local machine and import it to the current session with `ssh-add vagrant` 
3. Run `make deploy-k8s` to provision kubernetes cluster on your inventory
4. Run `make copy-kubeconfig` to copy kubeconfig to your local machine.
5. Test it with `kubectl get nodes`

### Nexus Installation

1. Redefine if it's needed [group_vars](ansible/group_vars)
2. Run `make deploy-nexus` to provision nexus node

### Gitlab Installation

1. Redefine if it's needed [group_vars](ansible/group_vars)
2. Run `make deploy-gitlab` to provision gitlab node
3. Run `make show-gitlab-root` to show gitlab url and credentials

### Gitlab Runner installation

1. Run `make deploy-runner`
2. Check that the runner is running `kubectl -n gitlab-runner get pods`
3. Open gitlab url, navigate to the `lab` group and check the runner is ready 

### Lab Projects Installation

1. Run `make create-gitlab-projects`
2. Check that three projects were created in the `gitlab`

We are ready for workshop.

## Boutique

Boutique is based on [Google microservices-demo project](https://github.com/GoogleCloudPlatform/microservices-demo)  
The targets of this chapter are:
- build all microservices for this project and place their images into the `nexus`
- implement continious integration
- deploy the project to `kubernetes`
- work on updating the project from old version to the newer one
- roll back the project
etc.

## Weavesocks

Weavesocks is based on [@weaveworks microservices project](https://github.com/microservices-demo/microservices-demo.git)  
The targets of this chapter are:
- work on deployment
- implement monitoring
- perform and analyse load tests