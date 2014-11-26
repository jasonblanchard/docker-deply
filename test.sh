#! /bin/bash

while true; do echo $(date); curl -si $1 | grep -A 5 "<body>"; sleep 0.2; done
