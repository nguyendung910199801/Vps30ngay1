FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cấu hình SSH login
RUN mkdir -p /var/run/sshd
RUN echo 'root:MatKhauCuaBan123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Profile/NOTFOUND/g' /etc/pam.d/sshd

# Tải và cài đặt tự động Cloudflare Tunnel (Không cần tên miền)
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb \
    && rm cloudflared.deb

EXPOSE 22

# Khởi động SSH và mở đường hầm nhận link công khai miễn phí
RUN echo '#!/bin/bash' > /start.sh \
    && echo '/usr/sbin/sshd' >> /start.sh \
    && echo 'echo "=== DANG KHOI TAO DUONG TRUYEN SSH ==="' >> /start.sh \
    && echo 'cloudflared tunnel --url tcp://localhost:22' >> /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
