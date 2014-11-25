FROM ubuntu:14.04

RUN \
  apt-get update && \
  apt-get install -y haproxy && \
  rm -rf /var/lib/apt/lists/*

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
RUN echo 'EXTRAOPTS="-db"' >>/etc/default/haproxy

CMD ["haproxy", "-f", "/etc/haproxy/haproxy.cfg", "-p", "-/var/run/haproxy.pid"]

EXPOSE 80
EXPOSE 443
