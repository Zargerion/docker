# ===============================================
# МНОГОЭТАПНАЯ СБОРКА (MULTI-STAGE BUILD)
# ===============================================
# Многоэтапная сборка позволяет использовать несколько FROM инструкций
# для создания промежуточных образов и копирования только необходимых артефактов
# в финальный образ. Это значительно уменьшает размер итогового образа.

# ===============================================
# ЭТАП 1: СБОРКА ПРИЛОЖЕНИЯ (Build Stage)
# ===============================================
# Используем полный образ Node.js для сборки приложения
FROM node:18-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы зависимостей
# Копируем сначала только package.json и package-lock.json для кэширования слоев
COPY package*.json ./

# Устанавливаем все зависимости (включая dev-dependencies)
RUN npm ci --only=production

# Копируем исходный код
COPY src/ ./src/
COPY public/ ./public/
COPY *.js ./
COPY *.json ./

# Собираем приложение для продакшена
RUN npm run build

# ===============================================
# ЭТАП 2: КОМПИЛЯЦИЯ БИНАРНОГО ФАЙЛА (Compiler Stage)
# ===============================================
FROM golang:1.21-alpine AS go-builder

WORKDIR /go-app

# Копируем Go файлы
COPY go-service/*.go ./
COPY go-service/go.mod ./
COPY go-service/go.sum ./

# Скачиваем зависимости
RUN go mod download

# Компилируем статический бинарный файл
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# ===============================================
# ЭТАП 3: ФИНАЛЬНЫЙ ОБРАЗ (Production Stage)
# ===============================================
# Используем минимальный базовый образ для продакшена
FROM nginx:alpine AS production

# Устанавливаем дополнительные пакеты
RUN apk add --no-cache curl ca-certificates

# Создаем пользователя для безопасности
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Копируем собранное приложение из builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Копируем бинарный файл из go-builder stage
COPY --from=go-builder /go-app/main /usr/local/bin/go-service

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Создаем директории для логов и данных
RUN mkdir -p /var/log/app /var/lib/app && \
    chown -R appuser:appgroup /var/log/app /var/lib/app

# Устанавливаем переменные окружения
ENV NODE_ENV=production
ENV API_URL=http://localhost:8080

# Открываем порты
EXPOSE 80 8080

# Настраиваем healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Копируем скрипт запуска
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Переключаемся на непривилегированного пользователя
USER appuser

# Запускаем приложение
CMD ["/usr/local/bin/start.sh"]

# ===============================================
# АЛЬТЕРНАТИВНЫЙ ПРИМЕР: PYTHON ПРИЛОЖЕНИЕ
# ===============================================
# Раскомментируйте этот блок для демонстрации Python multi-stage build

# # Этап сборки Python зависимостей
# FROM python:3.11-slim AS python-builder
# 
# WORKDIR /app
# 
# # Устанавливаем системные зависимости для сборки
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpq-dev \
#     && rm -rf /var/lib/apt/lists/*
# 
# # Копируем и устанавливаем зависимости
# COPY requirements.txt .
# RUN pip install --user --no-cache-dir -r requirements.txt
# 
# # Финальный этап для Python
# FROM python:3.11-slim AS python-production
# 
# # Копируем установленные пакеты из builder stage
# COPY --from=python-builder /root/.local /root/.local
# 
# # Обновляем PATH
# ENV PATH=/root/.local/bin:$PATH
# 
# WORKDIR /app
# COPY . .
# 
# CMD ["python", "app.py"]

# ===============================================
# КОМАНДЫ ДЛЯ СБОРКИ И ЗАПУСКА:
# ===============================================
#
# Сборка многоэтапного образа:
# docker build -t multistage-app .
#
# Сборка с указанием конкретного этапа (для отладки):
# docker build --target builder -t multistage-builder .
# docker build --target go-builder -t multistage-go-builder .
#
# Запуск финального образа:
# docker run -d -p 80:80 -p 8080:8080 --name multistage-container multistage-app
#
# Просмотр размеров образов:
# docker images | grep multistage
#
# Анализ слоев образа:
# docker history multistage-app
#
# Запуск промежуточного этапа для отладки:
# docker run -it --rm multistage-builder /bin/sh
#
# Очистка промежуточных образов:
# docker image prune -f
#
# Сборка с использованием BuildKit для улучшенной производительности:
# DOCKER_BUILDKIT=1 docker build -t multistage-app .
