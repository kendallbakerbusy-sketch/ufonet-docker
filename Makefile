.PHONY: build run shell gui stop clean help update test

# Variables
IMAGE_NAME = ufonet
CONTAINER_NAME = ufonet-container
GUI_CONTAINER_NAME = ufonet-gui

help:
	@echo "UFONet Docker Management"
	@echo "======================="
	@echo "make build       - Build the Docker image"
	@echo "make run         - Run UFONet with help command"
	@echo "make shell       - Start interactive bash shell"
	@echo "make gui         - Start UFONet Web GUI (port 9999)"
	@echo "make stop        - Stop all running containers"
	@echo "make clean       - Remove containers and image"
	@echo "make update      - Update UFONet and rebuild"
	@echo "make test        - Test the installation"
	@echo "make compose-up  - Start with docker-compose"
	@echo "make compose-down - Stop docker-compose services"

build:
	@echo "Building UFONet Docker image..."
	docker build -t $(IMAGE_NAME):latest .

run: build
	@echo "Running UFONet help..."
	docker run --rm -it $(IMAGE_NAME):latest python3 ufonet --help

shell: build
	@echo "Starting interactive shell..."
	docker run --rm -it \
		--privileged \
		--net=host \
		--name $(CONTAINER_NAME) \
		-v $(PWD)/botnet:/app/ufonet/botnet \
		-v $(PWD)/data:/app/ufonet/data \
		-v $(PWD)/maps:/app/ufonet/maps \
		$(IMAGE_NAME):latest \
		/bin/bash

gui: build
	@echo "Starting UFONet Web GUI on port 9999..."
	@mkdir -p botnet data maps
	docker run -d \
		--privileged \
		-p 9999:9999 \
		--name $(GUI_CONTAINER_NAME) \
		-v $(PWD)/botnet:/app/ufonet/botnet \
		-v $(PWD)/data:/app/ufonet/data \
		-v $(PWD)/maps:/app/ufonet/maps \
		$(IMAGE_NAME):latest \
		python3 ufonet --gui
	@echo "GUI started! Access at http://localhost:9999"
	@echo "View logs: docker logs -f $(GUI_CONTAINER_NAME)"

stop:
	@echo "Stopping UFONet containers..."
	-docker stop $(CONTAINER_NAME) $(GUI_CONTAINER_NAME) 2>/dev/null || true
	-docker rm $(CONTAINER_NAME) $(GUI_CONTAINER_NAME) 2>/dev/null || true

clean: stop
	@echo "Cleaning up UFONet Docker resources..."
	-docker rmi $(IMAGE_NAME):latest 2>/dev/null || true
	@echo "Clean complete!"

update:
	@echo "Updating UFONet..."
	docker run --rm -it $(IMAGE_NAME):latest \
		/bin/bash -c "cd /app/ufonet && git pull"
	@echo "Rebuilding image..."
	$(MAKE) build

test: build
	@echo "Testing UFONet installation..."
	docker run --rm $(IMAGE_NAME):latest python3 ufonet --version
	docker run --rm $(IMAGE_NAME):latest python3 -c "import scapy.all; print('Scapy: OK')"
	docker run --rm $(IMAGE_NAME):latest python3 -c "import requests; print('Requests: OK')"
	docker run --rm $(IMAGE_NAME):latest python3 -c "import GeoIP; print('GeoIP: OK')"
	@echo "All tests passed!"

compose-up:
	@mkdir -p botnet data maps
	docker-compose up -d

compose-down:
	docker-compose down

compose-build:
	docker-compose build

compose-logs:
	docker-compose logs -f

# Quick commands
download-zombies: build
	docker run --rm -it $(IMAGE_NAME):latest python3 ufonet --download-zombies

update-zombies: build
	docker run --rm -it $(IMAGE_NAME):latest python3 ufonet --update

list-zombies: build
	docker run --rm -it $(IMAGE_NAME):latest python3 ufonet --list-zombies
