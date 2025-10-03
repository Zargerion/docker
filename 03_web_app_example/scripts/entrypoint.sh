#!/bin/bash

# ===============================================
# ENTRYPOINT СКРИПТ ДЛЯ FLASK ПРИЛОЖЕНИЯ
# ===============================================
# Этот скрипт выполняется при запуске контейнера
# и подготавливает окружение для работы приложения

set -e  # Остановка при любой ошибке

echo "🐳 Запуск Flask приложения в Docker контейнере..."

# Функция для ожидания доступности сервиса
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    
    echo "⏳ Ожидание доступности $service_name ($host:$port)..."
    
    while ! nc -z "$host" "$port"; do
        echo "   $service_name недоступен, ожидание..."
        sleep 2
    done
    
    echo "✅ $service_name доступен!"
}

# Ожидание доступности базы данных
if [ -n "$DATABASE_URL" ]; then
    # Извлекаем хост и порт из DATABASE_URL
    DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    if [ -n "$DB_HOST" ] && [ -n "$DB_PORT" ]; then
        wait_for_service "$DB_HOST" "$DB_PORT" "PostgreSQL"
    fi
fi

# Ожидание доступности Redis
if [ -n "$REDIS_URL" ]; then
    REDIS_HOST=$(echo $REDIS_URL | sed -n 's/.*\/\/\([^:]*\):.*/\1/p')
    REDIS_PORT=$(echo $REDIS_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    if [ -n "$REDIS_HOST" ] && [ -n "$REDIS_PORT" ]; then
        wait_for_service "$REDIS_HOST" "$REDIS_PORT" "Redis"
    fi
fi

# Выполнение миграций базы данных
echo "🔄 Выполнение миграций базы данных..."
if [ "$FLASK_ENV" = "development" ]; then
    # В режиме разработки пересоздаем БД если нужно
    python -c "
from app import create_app, db
app = create_app()
with app.app_context():
    try:
        db.create_all()
        print('✅ Таблицы созданы')
    except Exception as e:
        print(f'⚠️  Ошибка создания таблиц: {e}')
"
else
    # В продакшене используем миграции
    flask db upgrade || echo "⚠️  Миграции не выполнены"
fi

# Создание директорий для логов и загрузок
mkdir -p /app/logs /app/uploads /app/data
echo "📁 Директории созданы"

# Установка прав доступа
chmod 755 /app/logs /app/uploads /app/data

# Вывод информации об окружении
echo "🔧 Информация об окружении:"
echo "   FLASK_ENV: ${FLASK_ENV:-production}"
echo "   APP_HOME: ${APP_HOME:-/app}"
echo "   DATABASE_URL: ${DATABASE_URL:0:30}..." # Показываем только начало URL
echo "   Пользователь: $(whoami)"
echo "   Рабочая директория: $(pwd)"

# Проверка health endpoint перед запуском
echo "🏥 Проверка готовности приложения..."

# Запуск команды, переданной как аргументы
echo "🚀 Запуск приложения: $@"
exec "$@"
