# ===============================================
# ПРОДВИНУТЫЕ ВОЗМОЖНОСТИ DOCKER
# ===============================================
# Этот Dockerfile демонстрирует расширенные функции Docker:
# - BuildKit возможности
# - Secrets и SSH
# - Cache mounts
# - Условная сборка
# - Кастомные build contexts

# syntax=docker/dockerfile:1.4
# Включаем BuildKit для расширенных возможностей

FROM ubuntu:22.04 AS base

# ===============================================
# BUILDKIT FEATURES
# ===============================================

# Используем cache mount для apt кэша
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential

# ===============================================
# SECRETS MANAGEMENT
# ===============================================

# Используем secret для приватных ключей
# Секрет передается через --secret id=ssh,src=~/.ssh/id_rsa
RUN --mount=type=secret,id=ssh,target=/root/.ssh/id_rsa,required=false \
    --mount=type=secret,id=known_hosts,target=/root/.ssh/known_hosts,required=false \
    if [ -f /root/.ssh/id_rsa ]; then \
        chmod 600 /root/.ssh/id_rsa && \
        echo "SSH ключ найден и настроен"; \
    else \
        echo "SSH ключ не предоставлен, пропускаем приватные репозитории"; \
    fi

# Используем secret для API токенов
RUN --mount=type=secret,id=api_token,target=/tmp/token,required=false \
    if [ -f /tmp/token ]; then \
        API_TOKEN=$(cat /tmp/token) && \
        echo "API токен загружен (длина: ${#API_TOKEN})"; \
        # Здесь можно использовать токен для скачивания приватных ресурсов
    else \
        echo "API токен не предоставлен"; \
    fi

# ===============================================
# CACHE MOUNTS
# ===============================================

# Используем cache mount для npm кэша
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Используем cache mount для pip кэша
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install -r requirements.txt

# ===============================================
# BIND MOUNTS
# ===============================================

# Используем bind mount для доступа к локальным файлам во время сборки
RUN --mount=type=bind,source=.,target=/src,rw \
    if [ -d /src/scripts ]; then \
        cp -r /src/scripts /app/; \
        echo "Скрипты скопированы из bind mount"; \
    fi

# ===============================================
# УСЛОВНАЯ СБОРКА
# ===============================================

# Этап для development
FROM base AS development
ARG DEVELOPMENT=false
RUN if [ "$DEVELOPMENT" = "true" ]; then \
        apt-get update && apt-get install -y \
        vim \
        htop \
        strace \
        tcpdump \
        net-tools; \
    fi

# Этап для production
FROM base AS production
ARG PRODUCTION=true
RUN if [ "$PRODUCTION" = "true" ]; then \
        apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# ===============================================
# HEREDOC SYNTAX (BuildKit 1.4+)
# ===============================================

# Создание файлов с помощью heredoc
RUN <<EOF
cat > /app/config.json << 'JSON'
{
    "environment": "${NODE_ENV:-production}",
    "features": {
        "buildkit": true,
        "secrets": true,
        "cache_mounts": true,
        "heredoc": true
    },
    "build_info": {
        "timestamp": "$(date -Iseconds)",
        "builder": "BuildKit"
    }
}
JSON
EOF

# Создание скрипта инициализации
RUN <<'SCRIPT'
cat > /app/init.sh << 'BASH'
#!/bin/bash
set -e

echo "🚀 Инициализация продвинутого контейнера..."

# Проверка наличия секретов
if [ -f "/run/secrets/db_password" ]; then
    echo "✅ Секрет базы данных найден"
    export DB_PASSWORD=$(cat /run/secrets/db_password)
fi

if [ -f "/run/secrets/api_key" ]; then
    echo "✅ API ключ найден"
    export API_KEY=$(cat /run/secrets/api_key)
fi

# Проверка BuildKit возможностей
echo "🔧 BuildKit возможности:"
echo "   - Cache mounts: ✅"
echo "   - Secrets: ✅"
echo "   - Heredoc: ✅"
echo "   - Multi-platform: ✅"

exec "$@"
BASH

chmod +x /app/init.sh
SCRIPT

# ===============================================
# MULTI-PLATFORM SUPPORT
# ===============================================

# Используем переменную TARGETPLATFORM для платформо-зависимых действий
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Сборка на: $BUILDPLATFORM для: $TARGETPLATFORM"

# Условная установка в зависимости от архитектуры
RUN case "$TARGETPLATFORM" in \
    "linux/amd64") \
        echo "Настройка для AMD64"; \
        ;; \
    "linux/arm64") \
        echo "Настройка для ARM64"; \
        ;; \
    "linux/arm/v7") \
        echo "Настройка для ARM v7"; \
        ;; \
    *) \
        echo "Неизвестная платформа: $TARGETPLATFORM"; \
        ;; \
    esac

# ===============================================
# ФИНАЛЬНЫЙ ЭТАП
# ===============================================

FROM production AS final

# Копируем артефакты из предыдущих этапов
COPY --from=development /usr/bin/vim /usr/bin/vim 2>/dev/null || true

WORKDIR /app

# Создаем пользователя
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /bin/bash appuser
RUN chown -R appuser:appuser /app

# Настраиваем volumes
VOLUME ["/app/data", "/app/logs", "/app/cache"]

# Настраиваем healthcheck с расширенными параметрами
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    --health-cmd="/app/healthcheck.sh" \
    CMD /app/healthcheck.sh || exit 1

# Создаем healthcheck скрипт
RUN <<'HEALTHCHECK'
cat > /app/healthcheck.sh << 'BASH'
#!/bin/bash

# Расширенная проверка здоровья
echo "🏥 Проверка здоровья контейнера..."

# Проверка основного процесса
if ! pgrep -f "main_process" > /dev/null; then
    echo "❌ Основной процесс не запущен"
    exit 1
fi

# Проверка доступности портов
if ! nc -z localhost 8080; then
    echo "❌ Порт 8080 недоступен"
    exit 1
fi

# Проверка использования памяти
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
if (( $(echo "$MEMORY_USAGE > 90" | bc -l) )); then
    echo "⚠️  Высокое использование памяти: ${MEMORY_USAGE}%"
fi

# Проверка дискового пространства
DISK_USAGE=$(df /app | awk 'NR==2{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    echo "⚠️  Мало места на диске: ${DISK_USAGE}%"
fi

echo "✅ Все проверки пройдены"
exit 0
BASH

chmod +x /app/healthcheck.sh
HEALTHCHECK

# Переключаемся на непривилегированного пользователя
USER appuser

# Настраиваем entrypoint
ENTRYPOINT ["/app/init.sh"]
CMD ["python3", "-m", "http.server", "8080"]

# ===============================================
# КОМАНДЫ ДЛЯ СБОРКИ С ПРОДВИНУТЫМИ ВОЗМОЖНОСТЯМИ:
# ===============================================
#
# Включение BuildKit:
# export DOCKER_BUILDKIT=1
# или
# docker buildx create --use
#
# Сборка с секретами:
# echo "secret_api_key_12345" | docker build --secret id=api_token,src=- .
# docker build --secret id=ssh,src=$HOME/.ssh/id_rsa .
#
# Сборка для разных платформ:
# docker buildx build --platform linux/amd64,linux/arm64 -t advanced-demo .
#
# Сборка с кастомным build context:
# docker build --build-context scripts=./external-scripts .
#
# Сборка с условными аргументами:
# docker build --build-arg DEVELOPMENT=true --target development .
# docker build --build-arg PRODUCTION=true --target production .
#
# Сборка с выводом метаданных:
# docker build --metadata-file metadata.json .
#
# Сборка с кэшированием:
# docker build --cache-from type=registry,ref=myregistry/cache .
# docker build --cache-to type=registry,ref=myregistry/cache .
#
# Запуск с секретами:
# echo "db_secret_password" | docker secret create db_password -
# docker service create --secret db_password advanced-demo
