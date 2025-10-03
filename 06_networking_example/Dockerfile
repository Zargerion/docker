# ===============================================
# ДЕМОНСТРАЦИЯ DOCKER СЕТЕЙ
# ===============================================
# Этот контейнер содержит утилиты для тестирования сетевого взаимодействия

FROM alpine:latest

LABEL description="Контейнер для демонстрации Docker сетей"
LABEL version="1.0.0"

# Устанавливаем сетевые утилиты
RUN apk add --no-cache \
    # Основные сетевые утилиты
    curl \
    wget \
    netcat-openbsd \
    bind-tools \
    iproute2 \
    iptables \
    tcpdump \
    # Мониторинг сети
    iftop \
    nethogs \
    nmap \
    # Веб-сервер для тестов
    nginx \
    # Утилиты для отладки
    busybox-extras \
    procps \
    htop \
    # Python для скриптов
    python3 \
    py3-pip \
    py3-requests \
    py3-flask

# Создаем директории
RUN mkdir -p /app/scripts /app/logs /var/www/html

# Копируем скрипты для тестирования сети
COPY scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Копируем веб-страницы для тестирования
COPY html/ /var/www/html/

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Создаем простой Python HTTP сервер
COPY server.py /app/server.py

# Переменные окружения
ENV CONTAINER_NAME=network-test
ENV HTTP_PORT=80
ENV PYTHON_PORT=8080

# Открываем порты для тестирования
EXPOSE 80 8080 3000 5000

# Создаем пользователя
RUN adduser -D -s /bin/sh netuser

# Копируем entrypoint скрипт
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:$HTTP_PORT/health || exit 1

# Точка входа
ENTRYPOINT ["/entrypoint.sh"]

# Команда по умолчанию
CMD ["multi-service"]

# ===============================================
# КОМАНДЫ ДЛЯ РАБОТЫ С СЕТЯМИ:
# ===============================================
#
# Создание пользовательских сетей:
# docker network create --driver bridge frontend-net
# docker network create --driver bridge backend-net
# docker network create --driver overlay --attachable swarm-net
#
# Запуск контейнеров в разных сетях:
# docker run -d --name web1 --network frontend-net -p 8001:80 network-demo
# docker run -d --name web2 --network backend-net -p 8002:80 network-demo
# docker run -d --name web3 --network none network-demo
#
# Подключение контейнера к дополнительным сетям:
# docker network connect backend-net web1
# docker network disconnect frontend-net web1
#
# Тестирование связности:
# docker exec web1 /app/scripts/test-connectivity.sh web2
# docker exec web1 ping web2
# docker exec web1 nslookup web2
#
# Просмотр сетевой информации:
# docker network ls
# docker network inspect frontend-net
# docker exec web1 ip addr show
# docker exec web1 netstat -tlnp
#
# Создание сети с настройками:
# docker network create --driver bridge \
#   --subnet=172.20.0.0/16 \
#   --ip-range=172.20.240.0/20 \
#   --gateway=172.20.0.1 \
#   custom-net
#
# Очистка сетей:
# docker network prune
# docker network rm frontend-net backend-net
