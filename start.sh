#! /bin/bash

docker run -p 5432 -d --name=PHUSIONDOCKER_DB_1 postgres && \
  docker run -d -p 8000:80 --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 jasonblanchard/phusion-app2 && \
  docker run -d -p 8001:80 --link PHUSIONDOCKER_DB_1:PHUSIONDOCKER_DB_1 jasonblanchard/phusion-app2 && \
  docker run -d -p 80:80 jasonblanchard/haproxy

