FROM debian:latest
MAINTAINER Markus Ackermann  <neradis@fusionfactory.de>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

ENV TZ Europe/Berlin

# fix for pseudo-terminals
ENV TERM xterm

# tooling for debug/dev ssh server, editor, admin cli tools, ...
# TODO: remove this later to reduce image size
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:rubchack' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN apt-get install -y aptitude emacs-nox tmux net-tools procps htop nmap curl sudo apt-file unzip

RUN apt-file update

# currently installing both drivers for Postgres and Mysql since switching currently for dev/debug
# TODO: install only final driver used later
RUN apt-get install -y python-pip python-psycopg2 python-mysqldb

COPY osqa-dbpedia/requirements.txt /

RUN pip install -r requirements.txt

EXPOSE 22 80

CMD ["django"]

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
