PWD = $(shell pwd)
IMAGE_NAME = $(shell basename ${PWD})
DOCKER_ID_USER = dezinger

.RECIPEPREFIX +=
.DEFAULT_GOAL := help
.PHONY: *

help:
	@echo "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run all tests; Usage: make test [t="<test-folder-1> <test-folder-2> ..."]
	@cd tests; \
	./test "$(t)"

build: ## Build image. Usage: make build TAG="7.0-cli"
	@docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` -t ${DOCKER_ID_USER}/${IMAGE_NAME}:$(TAG) -f docker/$(TAG).Dockerfile docker

build-73: ## Build PHP 7.3 images
	make build TAG="7.3-cli"
	make build TAG="7.3-fpm"
	make build TAG="7.3-apache"

build-all: ## Build all images
	make build-73

push-73: ## Push built PHP 7.3 images to Docker Hub
	@docker push ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3-cli
	@docker push ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3-fpm
	@docker push ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3-apache
	@docker tag ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3-cli ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3
	@docker tag ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3-cli ${DOCKER_ID_USER}/${IMAGE_NAME}:latest
	@docker push ${DOCKER_ID_USER}/${IMAGE_NAME}:7.3
	@docker push ${DOCKER_ID_USER}/${IMAGE_NAME}:latest

push-all: ## Push all built images to Docker Hub
	make push-73

build-and-push-73: ## Build and push PHP 7.3 images to Docker Hub
	make build-73
	make push-73

build-and-push: ## Build all images and push them to Docker Hub
	make build-all
	make push-all

clean: ## Clean all containers and images on the system
	-@docker ps -a -q | xargs docker rm -f
	-@docker images -q | xargs docker rmi -f
