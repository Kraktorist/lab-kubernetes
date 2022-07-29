install-all: install-hosts install-k8s install-haproxy install-gitlab install-nexus tf-output

install-hosts:
	cd ./envs/${labenv}/terraform && terraform init && terraform apply

destroy:
	cd ./envs/${labenv}/terraform && terraform destroy

install-k8s:
	rm -rf /tmp/kubespray;
	git clone https://github.com/kubernetes-sigs/kubespray.git /tmp/kubespray;
	ansible-playbook -i ./envs/${labenv}/ansible/ansible_inventory.yml --become /tmp/kubespray/cluster.yml

install-haproxy:
	ansible-galaxy install -r ./modules/ansible/haproxy/requirements.yml;
	ansible-playbook -i ./envs/${labenv}/ansible/ansible_inventory.yml --become ./modules/ansible/haproxy/main.yml

install-gitlab:
	ansible-playbook -i ./envs/${labenv}/ansible/ansible_inventory.yml --become ./modules/ansible/gitlab/main.yml

install-nexus:
	ansible-galaxy install -r ./modules/ansible/nexus/requirements.yml;
	ansible-playbook -i ./envs/${labenv}/ansible/ansible_inventory.yml --become modules/ansible/nexus/main.yml 

show-hosts:
	cd ./envs/${labenv}/terraform && terraform output

show-gitlab:
	ansible-playbook -i ./envs/${labenv}/ansible/ansible_inventory.yml --become ./modules/ansible/gitlab/main.yml --tags output