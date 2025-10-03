# ===============================================
# ПОЛНОЦЕННОЕ ВЕБ-ПРИЛОЖЕНИЕ С БАЗОЙ ДАННЫХ
# ===============================================
# Этот пример демонстрирует создание Flask веб-приложения
# с подключением к PostgreSQL базе данных

FROM python:3.11-slim

# Устанавливаем метаданные
LABEL maintainer="developer@example.com"
LABEL description="Flask веб-приложение с PostgreSQL"
LABEL version="1.0.0"

# Аргументы сборки
ARG APP_ENV=production
ARG DEBIAN_FRONTEND=noninteractive

# Переменные окружения
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=$APP_ENV
ENV APP_HOME=/app

# Устанавливаем рабочую директорию
WORKDIR $APP_HOME

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    # Зависимости для PostgreSQL
    libpq-dev \
    gcc \
    # Утилиты для отладки (можно убрать в продакшене)
    curl \
    netcat-traditional \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Копируем файл зависимостей и устанавливаем их
# Делаем это до копирования кода для лучшего кэширования
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY app/ ./app/
COPY static/ ./static/
COPY templates/ ./templates/
COPY migrations/ ./migrations/
COPY config.py .
COPY run.py .

# Создаем директории для данных и логов
RUN mkdir -p /app/logs /app/uploads /app/data

# Создаем непривилегированного пользователя
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Устанавливаем права доступа
RUN chown -R appuser:appuser /app
RUN chmod +x run.py

# Копируем скрипты
COPY scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Открываем порт приложения
EXPOSE 5000

# Настраиваем volumes для персистентных данных
VOLUME ["/app/logs", "/app/uploads", "/app/data"]

# Настраиваем health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Переключаемся на непривилегированного пользователя
USER appuser

# Точка входа - скрипт инициализации
ENTRYPOINT ["./scripts/entrypoint.sh"]

# Команда по умолчанию
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "120", "run:app"]

# ===============================================
# КОМАНДЫ ДЛЯ СБОРКИ И ЗАПУСКА:
# ===============================================
#
# Сборка образа:
# docker build -t flask-webapp .
#
# Запуск с PostgreSQL через docker-compose:
# docker-compose up -d
#
# Запуск отдельного контейнера с внешней БД:
# docker run -d -p 5000:5000 \
#   -e DATABASE_URL=postgresql://user:pass@host:5432/dbname \
#   -e SECRET_KEY=your-secret-key \
#   --name flask-app flask-webapp
#
# Запуск в режиме разработки:
# docker run -it -p 5000:5000 \
#   -v ${PWD}:/app \
#   -e FLASK_ENV=development \
#   flask-webapp flask run --host=0.0.0.0
#
# Выполнение миграций:
# docker exec flask-app python -m flask db upgrade
#
# Подключение к контейнеру:
# docker exec -it flask-app /bin/bash
#
# Просмотр логов:
# docker logs -f flask-app
