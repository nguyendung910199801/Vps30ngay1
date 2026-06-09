FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cau hinh SSH login
RUN mkdir -p /var/run/sshd
RUN echo 'root:MatKhauCuaBan123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Profile/NOTFOUND/g' /etc/pam.d/sshd

# Mo cong 22 cho SSH
EXPOSE 22

# Tao file start.sh chay SSH o che do foreground de container khong bi tat
RUN echo '#!/bin/bash' > /start.sh
RUN echo 'echo "=== Dang khoi dong SSH Server ==="' >> /start.sh
RUN echo 'exec /usr/sbin/sshd -D' >> /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
