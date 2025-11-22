.ONESHELL:
SHELL := /bin/bash
.DEFAULT_GOAL := build-docker


.PHONY: build-docker
build-docker:
	@TARGET=${TARGET}
	@SSH_FILE_PATH=${SSH_FILE_PATH}
	if [ "${TARGET}" == "" ]; then
		TARGET="flightmare"
		echo "Now compiling image target: ${TARGET}"
	fi
	eval $(ssh-agent)
	if [ -z "${SSH_FILE_PATH}" ]; then \
		if [ -f "${HOME}/.ssh/id_ed25519" ]; then \
			ssh-add -q "${HOME}/.ssh/id_ed25519"; \
		elif [ -f "${HOME}/.ssh/id_rsa" ]; then \
			ssh-add -q "${HOME}/.ssh/id_rsa"; \
		else \
			mapfile -t KEYS < <(find "${HOME}/.ssh" -type f -name 'id_*' ! -name '*.pub'); \
			if [ ${#KEYS[@]} -gt 0 ]; then \
				for k in "${KEYS[@]}"; do ssh-add -q "$k" || true; done; \
			else \
				echo "No SSH key found in ${HOME}/.ssh; continuing without ssh-add" >&2; \
			fi; \
		fi; \
	else \
		if [ -f "${SSH_FILE_PATH}" ]; then ssh-add -q "${SSH_FILE_PATH}"; else echo "SSH_FILE_PATH '${SSH_FILE_PATH}' not found; continuing without ssh-add" >&2; fi; \
	fi
	DOCKER_BUILDKIT=1 docker build \
		--network=host \
		-f Dockerfile \
		--target $${TARGET} \
		--ssh default=${SSH_AUTH_SOCK} \
		-t erl_flightmare:$${TARGET} .

.PHONY: docker-cache-clean
docker-cache-clean:
	docker builder prune --all --force

.PHONY: session
session:
	@CONT_NAME="${CONT_NAME}"
	@RUNTIME="${RUNTIME}"
	@TAG="${TAG}"
	@ENTRYPOINT="${ENTRYPOINT}"
	if [ "${CONT_NAME}" == "" ]; then
		CONT_NAME="flightmare_container"
	fi
	if [ "${TAG}" == "" ]; then
		TAG="flightmare"
	fi
	IMG_NAME=erl_flightmare:$${TAG}
	if [ "${RUNTIME}" = "nvidia" ]; then
		echo "RUNTIME is set to nvidia"
		xhost +
		docker run \
			--name $${CONT_NAME} \
			--runtime nvidia \
			-it \
			--rm \
			--privileged \
			--net=host \
			--gpus all \
			-e NVIDIA_DRIVER_CAPABILITIES=all \
			-e DISPLAY=${DISPLAY} \
			-v /dev/bus/usb:/dev/bus/usb \
			--device-cgroup-rule='c 189:* rmw' \
			--device /dev/video0 \
			--volume=/dev/input:/dev/input \
			--volume=${HOME}/.Xauthority:/root/.Xauthority:rw \
			--volume=/tmp/.X11-unix/:/tmp/.X11-unix \
			--volume=${PWD}/../flightmare_example/:/home/erl/flightmare_example \
			$${IMG_NAME} ${ENTRYPOINT}
	else
		xhost +
		docker run \
			--name $${CONT_NAME} \
			-it \
			--rm \
			--privileged \
			--net=host \
			-e DISPLAY=${DISPLAY} \
			-v /dev/bus/usb:/dev/bus/usb \
			--device-cgroup-rule='c 189:* rmw' \
			--device=/dev/dri:/dev/dri \
			--device /dev/video0 \
			--volume=/dev/input:/dev/input \
			--volume=${HOME}/.Xauthority:/root/.Xauthority:rw \
			--volume=/tmp/.X11-unix/:/tmp/.X11-unix \
			--volume=${PWD}/../flightmare_example/:/home/erl/flightmare_example \
			$${IMG_NAME} ${ENTRYPOINT}
	fi


.PHONY: join-session
join-session:
	@CONT_NAME="${CONT_NAME}"
	docker exec -it ${CONT_NAME} /bin/bash