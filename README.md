Testing load balancing Docker containers with HAProxy to get a zero-downtime deployment process.

Inspired by https://www.youtube.com/watch?v=q4MVVL6rmd4

# How to use
Run `./start.sh` to start:
- postgres
- 2 app containers
- an HAProxy container

Visit `[host]/haproxy?stats` to see the HAProxy stats. They are neat.

Run `./test.sh [host]` to start pinging port 80.

You should be able to take an app server offline with `docker stop [container id]` with no interruptions to the app service.

Profit.
