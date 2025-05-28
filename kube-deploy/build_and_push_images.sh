#!/bin/bash

CURRENT_DIR=$(pwd)
PROJECT_DIR=$(git rev-parse --show-toplevel)
DECOS_DOCKERFILE="${PROJECT_DIR}/decos/Dockerfile"
PG_DOCKERFILE="${PROJECT_DIR}/postgres-multiple-db/Dockerfile"

# load the container settings
source ${CURRENT_DIR}/.env


# Check if one among docker or podman is installed
if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
    echo "Neither Podman nor Docker is installed. Please install one of them to proceed."
    exit 1
fi

CONTAINER_CMD=''
if command -v podman &> /dev/null; then
    CONTAINER_CMD='podman'
else
    CONTAINER_CMD='docker'
fi

echo "Using container command: ${CONTAINER_CMD}"

${CONTAINER_CMD} login ${CONTAINER_REGISTRY} -u ${USERNAME}

cd "$PROJECT_DIR"

echo "== Building decos webapp container =="
${CONTAINER_CMD} build -t ${DECOS_IMG_NAME} -f ${DECOS_DOCKERFILE} .
if [ $? -ne 0 ]; then
    echo "Failed to build Decos webapp container."
    exit 1
fi
${CONTAINER_CMD} tag ${DECOS_IMG_NAME}:latest ${CONTAINER_REGISTRY}/${USER_NAME}/${DECOS_IMG_NAME}:${DECOS_IMG_TAG}
${CONTAINER_CMD} push ${CONTAINER_REGISTRY}/${USER_NAME}/${DECOS_IMG_NAME}:${DECOS_IMG_TAG}
if [ $? -ne 0 ]; then
    echo "Failed to push Decos webapp container."
    exit 1
fi

echo "== Building postgres container =="
${CONTAINER_CMD} build -t ${PG_IMG_NAME} -f ${PG_DOCKERFILE} .
if [ $? -ne 0 ]; then
    echo "Failed to build Postgres container."
    exit 1
fi
${CONTAINER_CMD} tag ${PG_IMG_NAME}:latest ${CONTAINER_REGISTRY}/${USER_NAME}/${PG_IMG_NAME}:${PG_IMG_TAG}
${CONTAINER_CMD} push ${CONTAINER_REGISTRY}/${USER_NAME}/${PG_IMG_NAME}:${PG_IMG_TAG}
if [ $? -ne 0 ]; then
    echo "Failed to push Postgres container."
    exit 1
fi

echo "== Successfully built and pushed ${DECOS_IMG_NAME}:${DECOS_IMG_TAG} and ${PG_IMG_NAME}:${PG_IMG_TAG} to ${CONTAINER_REGISTRY} =="

cd ${CURRENT_DIR}
