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

RUN mkdir /var/run/sshd
# Bạn có thể đổi 'MatKhauCuaBan123' thành mật khẩu riêng nếu muốn bảo mật hơn
RUN echo 'root:MatKhauCuaBan123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/Profile/NOTFOUND/g' /etc/pam.d/sshd

EXPOSE 22 8080

RUN echo '#!/bin/bash\n\
/usr/sbin/sshd\n\
\n\
if [ -n "$TUNNEL_TOKEN" ]; then\n\
    echo "--- Dang khoi dong Cloudflare Tunnel ---"\n\
    cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &\n\
else\n\
    echo "⚠️ CHU'A CA'U HI`NH TUNNEL_TOKEN TRE^N RAILWAY!"\n\
fi\n\
\n\
echo "=== VPS Ubuntu dang hoat dong ==="\n\
while true; do \n\
    echo -e "HTTP/1.1 200 OK\\nContent-Type: text/plain\\n\\nVPS is running" | nc -l -p 8080\n\
done' > /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
