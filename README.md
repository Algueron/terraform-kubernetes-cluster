# terraform-kubernetes-cluster
This project is used to generate the virtual machines required for my home Kubernetes cluster

## Pre-requisites

### Host setup
Setup a Ubuntu VM with at least 1 CPU and 2GB RAM.

### Setup passwordless sudo

 - Edit your /etc/sudoers to add your account to passwordless sudoers
````bash
sudo vi /etc/sudoers.d/algueron
````
 - Add the following line to the file :
````
algueron ALL=(ALL) NOPASSWD:ALL
````
 - Save and exit

### Terraform setup

 - Add the HashiCorp GPG key.
````bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
````
 - Add the official HashiCorp Linux repository.
````bash
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
````
 - Update and install Terraform.
````bash
sudo apt-get update && sudo apt-get install terraform
````

### Deployment

Before that, make sure the Ubuntu Golden Image is available on the Proxmox cluster (https://github.com/Algueron/proxmox-golden-images).

 - Clone this repository
````bash
git clone https://github.com/Algueron/terraform-kubernetes-cluster.git
````
 - Move into the directory
````bash
cd terraform-kubernetes-cluster
````
 - Download Terraform requirements
````bash
terraform init
````
 - Validate the scripts
````bash
terraform validate
````
 - Plan the deployment
````bash
terraform plan -out myplan -var "pm_api_url=https://<YOUR PROXMOX IP>:8006/api2/json" -var "pm_user=root@pam" -var "pm_password=<YOUR PROXMOX PASSWORD>" -var "ssh_key=<YOUR SSH KEY>"
````
 - Deploy
````bash
terraform apply myplan
````

## Kubernetes Deployment

 - Install PIP
````bash
sudo apt install -y python3-pip
````
 - Clone Kubespray repository
````bash
cd ~/
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.18
````
 - Install Kubespray requirements
````bash
sudo pip3 install -r requirements.txt
````
 - Deploy the cluster
````bash
ansible-playbook -i ~/terraform-kubernetes-cluster/inventory/mycluster/hosts.yaml -u algueron --private-key=~/.ssh/id_rsa --become cluster.yml
````

## Kubernetes Connection

 - Download kubectl (https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/#installer-kubectl-sur-windows)
 - Copy kubectl on your machine and adds it to the PATH
 - Connect using SSH to one of the Kubernetes control plane node created previously
 - Retrieve the file /etc/kubernetes/admin.conf and copy it onto your local machine
 - Change the variable clusters.cluster[0].server to use the external IP
 - Set an environment variable KUBECONFIG pointing to the file retrieved
