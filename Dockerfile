FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd
RUN echo 'root:MatKhauCuaBan123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Profile/NOTFOUND/g' /etc/pam.d/sshd

EXPOSE 22 8080

# Tao file start.sh sach se, chay truc tiep khong can tunnel
RUN echo '#!/bin/bash' > /start.sh
RUN echo '/usr/sbin/sshd' >> /start.sh
RUN echo 'echo "=== VPS Ubuntu dang hoat dong nuot na ==="' >> /start.sh
RUN echo 'while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nVPS is running" | nc -l -p 8080; done' >> /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
