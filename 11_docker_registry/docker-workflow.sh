#!/bin/bash

# 🐳 Docker Hub Workflow Script
# Простой скрипт: логин → билд → пуш → пулл → запуск

set -e  # Остановка при ошибке

# Загрузка конфигурации из env файла
if [ -f "env.config" ]; then
    source env.config
else
    echo "❌ Файл env.config не найден!"
    exit 1
fi

echo "🚀 Начинаем Docker Hub workflow..."
echo "👤 Username: $DOCKER_USERNAME"
echo "📦 App: $APP_NAME:$APP_TAG"

# 1. 🔐 Логин в Docker Hub
echo "📝 Шаг 1: Логин в Docker Hub"
echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin
echo "✅ Успешный логин!"

# 2. 🏗️ Билд образа
echo "📝 Шаг 3: Сборка Docker образа"
docker build -t $DOCKER_USERNAME/$APP_NAME:$APP_TAG .
echo "✅ Образ собран!"

# 4. 📤 Пуш в Docker Hub
echo "📝 Шаг 4: Публикация в Docker Hub"
docker push $DOCKER_USERNAME/$APP_NAME:$APP_TAG
echo "✅ Образ опубликован!"

# 5. 🗑️ Очистка локального образа
echo "📝 Шаг 5: Очистка локального образа"
docker rmi $DOCKER_USERNAME/$APP_NAME:$APP_TAG
echo "✅ Локальный образ удален!"

# 6. 📥 Пулл из Docker Hub
echo "📝 Шаг 6: Загрузка образа из Docker Hub"
docker pull $DOCKER_USERNAME/$APP_NAME:$APP_TAG
echo "✅ Образ загружен!"

# 7. 🚀 Запуск с Docker Compose
echo "📝 Шаг 7: Запуск приложения с Docker Compose"
export DOCKER_USERNAME=$DOCKER_USERNAME
export APP_NAME=$APP_NAME
export APP_TAG=$APP_TAG
docker-compose up -d
echo "✅ Приложение запущено!"

# 8. 🔍 Проверка работы
echo "📝 Шаг 8: Проверка работы приложения"
sleep 5
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Приложение работает! Откройте http://localhost:8080"
else
    echo "❌ Приложение не отвечает"
fi

# 9. 📊 Информация о контейнерах
echo "📝 Шаг 9: Информация о запущенных контейнерах"
docker-compose ps

echo ""
echo "🎉 Docker Hub workflow завершен!"
echo "🌐 Приложение доступно по адресу: http://localhost:8080"
echo "🛑 Для остановки выполните: docker-compose down"
echo ""
echo "📋 Полезные команды:"
echo "  docker-compose logs -f    # Просмотр логов"
echo "  docker-compose ps         # Статус контейнеров"
echo "  docker-compose down       # Остановка"
echo "  docker images $DOCKER_USERNAME/*  # Ваши образы"
echo ""
echo "🔒 Безопасность:"
echo "  - Используйте Access Token вместо пароля"
echo "  - Не коммитьте env.config в git"
echo "  - Получите токен: https://hub.docker.com/settings/security"
