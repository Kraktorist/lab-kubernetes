ifndef VERBOSE
MAKEFLAGS += --silent
endif
SHELL := /bin/bash

install-hosts:
	cd ./terraform && terraform apply

destroy:
	cd ./terraform && terraform destroy

deploy-k8s:
	tmp=$$(mktemp -d); \
	echo $${tmp}; \
	git clone https://github.com/kubernetes-sigs/kubespray.git $${tmp}; \
	ansible-playbook -i ./ansible/ansible_inventory.yml --become $${tmp}/cluster.yml; \
	rm -rf $${tmp}

deploy-haproxy:
	ansible-galaxy install -r ./modules/ansible/haproxy/requirements.yml;
	ansible-playbook -i ./ansible/ansible_inventory.yml --become ./modules/ansible/haproxy/main.yml

deploy-gitlab:
	ansible-playbook -i ./ansible/ansible_inventory.yml --become ./modules/ansible/gitlab/main.yml

deploy-nexus:
	ansible-galaxy install -r ./modules/ansible/nexus/requirements.yml;
	ansible-playbook -i ./ansible/ansible_inventory.yml --become modules/ansible/nexus/main.yml 

show-hosts:
	cd ./terraform && terraform output -json | jq '.nodes_ips.value'

show-gitlab-root:
	ansible-playbook -i ./ansible/ansible_inventory.yml --become ./modules/ansible/gitlab/main.yml --tags output

deploy-runner:
	ansible-playbook -i ./ansible/ansible_inventory.yml ./modules/ansible/gitlab/main.yml --tags token

create-gitlab-projects:
	ansible-playbook -i ./ansible/ansible_inventory.yml --become ./modules/ansible/gitlab/main.yml --tags projects



provision-nexus:
	set -e; \
	docker_host=$$(python -c \
	  "import yaml; \
	   x=yaml.safe_load(open('./ansible/ansible_inventory.yml')); \
	   nexus=x['all']['children']['nexus']['hosts']; \
	   print(nexus[list(nexus.keys())[0]]['ansible_host'])"):9080; \
	read -p "Enter docker user: " username; \
	read -s -p "Enter docker password: " password; \
	docker login --username $${username} --password $${password} $${docker_host}; \
	tmp=$$(mktemp -d); \
	git clone https://github.com/microservices-demo/microservices-demo $${tmp}; \
	images=$$(kubectl apply -f $${tmp}/deploy/kubernetes/complete-demo.yaml \
  		--dry-run=client  -o jsonpath="{..image}" | tr -s '[[:space:]]' '\n' | sort | uniq); \
	for image in $${images}; do \
	docker pull $${image}; \
	docker tag $${image} $${docker_host}/$${image}; \
	docker push $${docker_host}/$${image} || true; \
	docker image rm $${image}; \
	docker image rm $${docker_host}/$${image}; \
	done 

copy-kubeconfig:
	set -e; \
	master_host=$$(python -c \
	  "import yaml; \
	   x=yaml.safe_load(open('./ansible/ansible_inventory.yml')); \
	   k8s=x['all']['children']['k8s_cluster']['children']['kube_control_plane']['hosts']; \
	   print(k8s[list(k8s.keys())[0]]['ansible_host'])"); \
	ssh_user=$$(python -c \
	  "import yaml; \
	   x=yaml.safe_load(open('./ansible/ansible_inventory.yml')); \
	   print(x['all']['vars']['ansible_user'])"); \
	ssh $${ssh_user}@$${master_host} sudo cat /root/.kube/config>~/.kube/config; \
	kubectl config set-cluster cluster.local \
	    --server=https://$${master_host}:6443/ \
		--insecure-skip-tls-verify=true