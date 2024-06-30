#!/usr/bin/make
SHELL = /bin/sh
export UID=$(shell id -u)
export GID=$(shell id -g)
export GIT_VERSION=$(shell  git log -1 --pretty=format:"%H")
export GIT_BRANCH=$(shell  git rev-parse --abbrev-ref HEAD)


docker-login:
	aws ecr get-login-password --region eu-west-2 --profile tbc-profile | docker login --username AWS --password-stdin  ${REGISTRY_URL}

# Then verify that you can access AWS services with that profile.
get-identity:
	aws sts get-caller-identity --profile tbc-profile

kube-update:
	aws eks update-kubeconfig   --name ${GIT_BRANCH}-tbc-application  --region eu-west-2 --profile tbc-profile

can-i:
	kubectl auth can-i "*" "*"

apply:
	terraform apply -auto-approve --var-file variables/${GIT_BRANCH}.tfvars


down:
	terraform destroy -auto-approve --var-file variables/${GIT_BRANCH}.tfvars

plan:
	terraform plan --var-file variables/${GIT_BRANCH}.tfvars

init:
	terraform init --var-file variables/${GIT_BRANCH}.tfvars  -backend-config="profile=tbc-profile"