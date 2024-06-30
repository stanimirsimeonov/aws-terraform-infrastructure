#!/usr/bin/make
SHELL = /bin/sh
export UID=$(shell id -u)
export GID=$(shell id -g)
export GIT_VERSION=$(shell  git log -1 --pretty=format:"%H")
export REGISTRY_URL="879978903444.dkr.ecr.eu-west-2.amazonaws.com"
export REPOSITORY_NAME="basephp-cli"


# Check if there is an environment AWS_ACCOUNT_ID
ifndef  REGISTRY_URL
$(error REGISTRY_URL is not set as env)
endif

ifndef REPOSITORY_NAME
$(error REPOSITORY_NAME is not set as env)
endif



check-users:
	@echo ${UID}
	@echo ${GID}


build-7.4:
	docker build \
			--compress \
			--no-cache \
			--target=cli \
			--build-arg PHP_VER=7.4-cli-alpine3.16 \
			-t ${REGISTRY_URL}/${REPOSITORY_NAME}:7.4-latest \
			-t ${REGISTRY_URL}/${REPOSITORY_NAME}:7.4-${GIT_VERSION} \
			-f Dockerfile \
			.
build-8.1-1:
	docker build \
			--compress \
			--no-cache \
			--target=cli \
			--build-arg PHP_VER=8.1.12-cli-alpine3.16 \
			-t ${REGISTRY_URL}/${REPOSITORY_NAME}:8.1.1-latest \
			-t ${REGISTRY_URL}/${REPOSITORY_NAME}:8.1.1-${GIT_VERSION} \
			-f Dockerfile \
			.
build: build-7.4 build-8.1-1
push:
	docker push  ${REGISTRY_URL}/${REPOSITORY_NAME}:7.4-latest
	docker push  ${REGISTRY_URL}/${REPOSITORY_NAME}:8.1.1-latest
	docker push  ${REGISTRY_URL}/${REPOSITORY_NAME}:8.1.1-${GIT_VERSION}
	docker push  ${REGISTRY_URL}/${REPOSITORY_NAME}:7.4-${GIT_VERSION}



docker-login:
	aws ecr get-login-password --region eu-west-2 --profile tbc-profile | docker login --username AWS --password-stdin  ${REGISTRY_URL}

# Then verify that you can access AWS services with that profile.
get-identity:
	aws sts get-caller-identity --profile cli-tbc-development

kube-update:
	aws eks update-kubeconfig   --name tbc-k8s-cluster  --region eu-west-2 --profile eks-admin

can-i:
	kubectl auth can-i "*" "*"


down:
	docker-compose down

prune:
	docker system prune --all --force --volumes