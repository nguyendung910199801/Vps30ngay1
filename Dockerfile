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

RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb \
    && rm cloudflared.deb

RUN mkdir -p /var/run/sshd
RUN echo 'root:MatKhauCuaBan123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Profile/NOTFOUND/g' /etc/pam.d/sshd

EXPOSE 22 8080

# Tạo file khởi động bằng cách nối từng dòng đơn giản để tránh lỗi xuống dòng trên điện thoại
RUN echo '#!/bin/bash' > /start.sh
RUN echo '/usr/sbin/sshd' >> /start.sh
RUN echo 'if [ -n "$TUNNEL_TOKEN" ]; then' >> /start.sh
RUN echo '    echo "--- Dang khoi dong Cloudflare Tunnel ---"' >> /start.sh
RUN echo '    cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &' >> /start.sh
RUN echo 'else' >> /start.sh
RUN echo '    echo "⚠️ CHUA CAU HINH TUNNEL_TOKEN!"' >> /start.sh
RUN echo 'fi' >> /start.sh
RUN echo 'echo "=== VPS Ubuntu dang hoat dong ==="' >> /start.sh
RUN echo 'while true; do' >> /start.sh
RUN echo '    echo -e "HTTP/1.1 200 OK\\n\\nVPS is running" | nc -l -p 8080' >> /start.sh
RUN echo 'done' >> /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
 
