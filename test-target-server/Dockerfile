FROM almalinux:8.5

RUN dnf -y install openssh-server
RUN echo 'root:password' | chpasswd

ENTRYPOINT ["/sbin/init"]
