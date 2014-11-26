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
REDIS_IMAGE="redis"

set_health () {
  docker run -it \
    --net host \
    --rm=true \
    nathanleclaire/curl \
    curl --user super:secret "localhost:$1/health/$2" &>/dev/null || true

  sleep 1
}

run_app_containers_from_image () {
  for i in {0..1}; do
    PORT=800${i}

    echo "Updaing ${APP_CONTAINER}_800${i}"

    # Deregister with HAProxy
    set_health $PORT 'off'
    # Let it finish services requests
    sleep 5

    docker stop ${APP_CONTAINER}_800${i} &>/dev/null || true
    docker rm ${APP_CONTAINER}_800${i} &>/dev/null || true

    docker run -d \
      -p ${PORT}:80 \
      --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 \
      --link redis:redis \
      -e LOCAL_PORT=${PORT} \
      --name ${APP_CONTAINER}_800${i} \
      $1

    # Let the app come back online
    sleep 10

    # Re-register with HAProxy
    set_health $PORT 'on'
  done
}

case $1 in
  up)
    docker pull ${TAGGED_IMAGE}
    docker pull ${HAPROXY_IMAGE}

    docker run -d --name=PHUSIONDOCKER_DB_1 ${DATABASE_IMAGE} && \
    docker run -d --name=redis redis && \
    run_app_containers_from_image ${TAGGED_IMAGE}

    docker run --net host --name=haproxy -d -p 80:80 ${HAPROXY_IMAGE}
    ;;

  deploy)
    docker pull ${TAGGED_IMAGE}
    run_app_containers_from_image ${TAGGED_IMAGE}
    ;;

  down)
    docker stop app_8001
    docker rm app_8001
    docker stop app_8000
    docker rm app_8000
    docker stop PHUSIONDOCKER_DB_1
    docker rm PHUSIONDOCKER_DB_1
    docker stop haproxy
    docker rm haproxy
    docker stop redis
    docker rm redis
    ;;
  rollback)
    run_app_containers_from_image ${APP_IMAGE}:$2
    ;;
  *)
    echo "Usage: deploy.sh [up|deploy|rollback]"
    exit 1
esac
