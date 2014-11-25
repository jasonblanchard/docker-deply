#! /bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

APP_IMAGE="jasonblanchard/phusion-app2"
IMAGE_TAG="latest"
TAGGED_IMAGE=${APP_IMAGE}:${IMAGE_TAG}
APP_CONTAINER="app"
NUM_BACKUPS=2
HAPROXY_IMAGE="jasonblanchard/haproxy"
DATABASE_IMAGE="postgres"

run_app_containers_from_image () {
  for i in {0..1}; do
    PORT=800${i}

    echo "Updaing ${APP_CONTAINER}_800${i}"

    docker stop ${APP_CONTAINER}_800${i} &>/dev/null || true
    docker rm ${APP_CONTAINER}_800${i} &>/dev/null || true

    docker run -d \
      -p ${PORT}:80 \
      --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 \
      --name ${APP_CONTAINER}_800${i} \
      $1

    sleep 12
  done
}

case $1 in
  up)
    docker pull ${TAGGED_IMAGE}
    docker run -d --name=PHUSIONDOCKER_DB_1 ${DATABASE_IMAGE} && \
    docker run -d -p 8000:80 --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 --name app_8000 ${APP_IMAGE}  && \
    # Prevents a weird thing with running migrations
    sleep 3 && \
    docker run -d -p 8001:80 --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 --name app_8001 ${APP_IMAGE}  && \
    docker run -d -p 80:80 ${HAPROXY_IMAGE}
    ;;

  deploy)
    docker pull ${TAGGED_IMAGE}
    run_app_containers_from_image ${TAGGED_IMAGE}
    ;;

  rollback)
    run_app_containers_from_image ${APP_IMAGE}:$2
    ;;
  *)
    echo "Usage: deploy.sh [up|deploy|rollback]"
    exit 1
esac
