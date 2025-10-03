# 🏆 Лучшие практики Docker

Этот документ содержит проверенные временем лучшие практики для работы с Docker, которые помогут вам создавать эффективные, безопасные и поддерживаемые контейнеризованные приложения.

## 📋 Содержание

1. [Оптимизация Dockerfile](#оптимизация-dockerfile)
2. [Безопасность](#безопасность)
3. [Производительность](#производительность)
4. [Хранение данных](#хранение-данных)
5. [Сети](#сети)
6. [Мониторинг и логирование](#мониторинг-и-логирование)
7. [CI/CD интеграция](#cicd-интеграция)
8. [Продакшен готовность](#продакшен-готовность)

## 🐳 Оптимизация Dockerfile

### 1. Используйте минимальные базовые образы

```dockerfile
# ❌ Плохо - большой образ
FROM ubuntu:latest

# ✅ Хорошо - минимальный образ
FROM alpine:3.18
# или
FROM scratch  # для статических бинарников
# или
FROM node:18-alpine  # alpine версии
```

### 2. Многоэтапная сборка для уменьшения размера

```dockerfile
# ✅ Хорошо - многоэтапная сборка
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

### 3. Оптимизируйте порядок инструкций для кэширования

```dockerfile
# ✅ Хорошо - зависимости устанавливаются до копирования кода
FROM node:18-alpine
WORKDIR /app

# Сначала копируем файлы зависимостей
COPY package*.json ./
RUN npm ci --only=production

# Затем копируем код (изменяется чаще)
COPY . .

CMD ["node", "server.js"]
```

### 4. Объединяйте RUN инструкции

```dockerfile
# ❌ Плохо - много слоев
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get clean

# ✅ Хорошо - один слой
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 5. Используйте .dockerignore

```dockerignore
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.pytest_cache
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
pip-log.txt
pip-delete-this-directory.txt
.tox
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.DS_Store
.vscode
```

### 6. Не используйте latest тег

```dockerfile
# ❌ Плохо - непредсказуемые обновления
FROM node:latest

# ✅ Хорошо - конкретная версия
FROM node:18.17.1-alpine3.18
```

### 7. Используйте COPY вместо ADD

```dockerfile
# ❌ Плохо - ADD имеет скрытую функциональность
ADD app.tar.gz /app/

# ✅ Хорошо - COPY более предсказуем
COPY app/ /app/
```

### 8. Устанавливайте явные версии пакетов

```dockerfile
# ❌ Плохо
RUN pip install flask requests

# ✅ Хорошо
RUN pip install flask==2.3.3 requests==2.31.0
```

## 🔒 Безопасность

### 1. Не запускайте контейнеры от root

```dockerfile
# Создание непривилегированного пользователя
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Установка владельца файлов
RUN chown -R appuser:appuser /app

# Переключение на пользователя
USER appuser
```

### 2. Используйте read-only файловую систему

```bash
# Запуск с read-only FS
docker run --read-only --tmpfs /tmp myapp
```

```dockerfile
# В Dockerfile
VOLUME ["/tmp", "/var/log"]
```

### 3. Ограничивайте capabilities

```bash
# Удаление всех capabilities
docker run --cap-drop=ALL myapp

# Добавление только необходимых
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp
```

### 4. Используйте secrets для чувствительных данных

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: myapp
    secrets:
      - db_password
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### 5. Сканируйте образы на уязвимости

```bash
# Использование Trivy
trivy image myapp:latest

# Использование Docker Scout (новый инструмент Docker)
docker scout cves myapp:latest
```

### 6. Не включайте секреты в образ

```dockerfile
# ❌ Плохо - секрет попадет в образ
RUN echo "secret_key=12345" > /app/config

# ✅ Хорошо - используйте переменные окружения или secrets
ENV SECRET_KEY_FILE=/run/secrets/secret_key
```

## ⚡ Производительность

### 1. Используйте init процесс для корректной обработки сигналов

```bash
# Запуск с init
docker run --init myapp
```

```dockerfile
# Или в Dockerfile
FROM alpine:3.18
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["myapp"]
```

### 2. Оптимизируйте использование памяти

```bash
# Ограничение памяти
docker run -m 512m myapp

# Ограничение swap
docker run -m 512m --memory-swap 512m myapp
```

### 3. Используйте health checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

### 4. Оптимизируйте слои образа

```bash
# Анализ слоев с помощью dive
dive myapp:latest

# Просмотр истории образа
docker history myapp:latest
```

### 5. Используйте BuildKit для улучшенной производительности

```bash
# Включение BuildKit
export DOCKER_BUILDKIT=1
docker build .

# Или с buildx
docker buildx build .
```

### 6. Кэширование зависимостей

```dockerfile
# Используйте cache mounts (BuildKit)
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y package
```

## 💾 Хранение данных

### 1. Используйте именованные volumes для персистентных данных

```bash
# Создание именованного volume
docker volume create myapp-data

# Использование
docker run -v myapp-data:/app/data myapp
```

### 2. Избегайте хранения данных в контейнере

```dockerfile
# ✅ Хорошо - данные вне контейнера
VOLUME ["/app/data", "/app/logs"]
```

### 3. Используйте bind mounts для разработки

```bash
# Для разработки - bind mount
docker run -v $(pwd):/app myapp

# Для продакшена - именованный volume
docker run -v myapp-data:/app/data myapp
```

### 4. Настройте правильные права доступа

```dockerfile
# Создание директорий с правильными правами
RUN mkdir -p /app/data /app/logs && \
    chown -R appuser:appuser /app && \
    chmod 755 /app/data
```

## 🌐 Сети

### 1. Используйте пользовательские сети

```bash
# Создание пользовательской сети
docker network create myapp-network

# Запуск контейнеров в сети
docker run --network myapp-network myapp
```

### 2. Изолируйте сервисы по сетям

```yaml
# docker-compose.yml
version: '3.8'
services:
  frontend:
    networks:
      - frontend-net
      - backend-net
  
  backend:
    networks:
      - backend-net
      - db-net
  
  database:
    networks:
      - db-net  # Только backend может обращаться к БД

networks:
  frontend-net:
  backend-net:
  db-net:
    internal: true  # Нет доступа в интернет
```

### 3. Используйте DNS имена вместо IP адресов

```bash
# ✅ Хорошо - использование DNS имен
curl http://backend-service:8080/api

# ❌ Плохо - хардкод IP адресов
curl http://172.18.0.3:8080/api
```

## 📊 Мониторинг и логирование

### 1. Настройте централизованное логирование

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: myapp
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: myapp.logs
```

### 2. Используйте структурированные логи

```python
# Python пример
import json
import logging

logging.basicConfig(format='%(message)s')
logger = logging.getLogger(__name__)

# Структурированный лог
log_entry = {
    "timestamp": "2023-01-01T12:00:00Z",
    "level": "INFO",
    "message": "User login",
    "user_id": 12345,
    "ip_address": "192.168.1.100"
}
logger.info(json.dumps(log_entry))
```

### 3. Настройте ротацию логов

```bash
# Ограничение размера логов
docker run --log-opt max-size=10m --log-opt max-file=3 myapp
```

### 4. Мониторинг ресурсов

```yaml
# Prometheus мониторинг
version: '3.8'
services:
  app:
    image: myapp
    ports:
      - "8080:8080"
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=8080"
      - "prometheus.io/path=/metrics"
```

## 🚀 CI/CD интеграция

### 1. Используйте multi-stage builds для CI

```dockerfile
FROM node:18-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test

FROM node:18-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
CMD ["node", "server.js"]
```

### 2. Тегирование образов

```bash
# Семантическое версионирование
docker build -t myapp:1.2.3 .
docker build -t myapp:1.2 .
docker build -t myapp:1 .
docker build -t myapp:latest .

# Git-based тегирование
docker build -t myapp:$(git rev-parse --short HEAD) .
docker build -t myapp:$(git describe --tags) .
```

### 3. Кэширование в CI

```yaml
# GitHub Actions пример
- name: Build Docker image
  run: |
    docker build \
      --cache-from myregistry/myapp:cache \
      --tag myapp:latest \
      --tag myregistry/myapp:cache \
      .
    
- name: Push cache
  run: docker push myregistry/myapp:cache
```

### 4. Безопасность в CI

```yaml
# Не используйте privileged режим в CI
- name: Build image
  run: docker build --no-cache .
  
# Сканирование на уязвимости
- name: Scan image
  run: trivy image myapp:latest
```

## 🏭 Продакшен готовность

### 1. Graceful shutdown

```dockerfile
# Правильная обработка SIGTERM
STOPSIGNAL SIGTERM

# В коде приложения (Node.js пример)
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    server.close(() => {
        console.log('Process terminated');
    });
});
```

### 2. Ресурсные ограничения

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: myapp
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### 3. Политика перезапуска

```yaml
services:
  app:
    image: myapp
    restart: unless-stopped  # или on-failure
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

### 4. Конфигурация через переменные окружения

```dockerfile
# Используйте переменные окружения для конфигурации
ENV NODE_ENV=production
ENV PORT=8080
ENV DB_HOST=database
ENV LOG_LEVEL=info
```

### 5. Подготовка к масштабированию

```yaml
# Stateless приложения
services:
  app:
    image: myapp
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
```

## 🔧 Инструменты и утилиты

### 1. Полезные инструменты

```bash
# Анализ размера образа
dive myapp:latest

# Оптимизация образа
docker-slim build myapp:latest

# Сканирование безопасности
trivy image myapp:latest
grype myapp:latest

# Линтинг Dockerfile
hadolint Dockerfile

# Анализ Docker Compose
docker-compose config --quiet
```

### 2. Мониторинг

```bash
# Статистика контейнеров
docker stats

# Системная информация
docker system df
docker system events

# Анализ логов
docker logs --since 1h mycontainer
```

### 3. Отладка

```bash
# Подключение к контейнеру
docker exec -it mycontainer /bin/sh

# Копирование файлов
docker cp mycontainer:/app/logs ./logs

# Анализ сети
docker network inspect mynetwork
```

## 📝 Чек-лист для продакшена

- [ ] Используется минимальный базовый образ
- [ ] Контейнер запускается от непривилегированного пользователя
- [ ] Настроен health check
- [ ] Логи выводятся в stdout/stderr
- [ ] Секреты не хранятся в образе
- [ ] Используются именованные volumes для данных
- [ ] Настроены ресурсные ограничения
- [ ] Образ просканирован на уязвимости
- [ ] Настроена политика перезапуска
- [ ] Приложение корректно обрабатывает SIGTERM
- [ ] Используются конкретные версии базовых образов
- [ ] Настроено централизованное логирование
- [ ] Есть мониторинг ресурсов
- [ ] Данные персистентны между перезапусками

---

Следование этим практикам поможет вам создать надежные, безопасные и эффективные Docker-контейнеры, готовые к использованию в продакшене.
