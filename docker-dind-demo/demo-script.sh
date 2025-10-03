#!/bin/bash

# 🐳 Docker-in-Docker Демонстрационный скрипт

echo "🚀 Запуск Docker-in-Docker демонстрации..."

# Запустить DinD
echo "📦 Запускаем Docker-in-Docker..."
docker-compose up -d

# Ждем запуска
echo "⏳ Ждем запуска сервисов..."
sleep 10

# Проверить статус
echo "📊 Статус сервисов:"
docker-compose ps

echo ""
echo "🔍 Проверяем Docker внутри DinD..."

# Подключиться к клиенту и проверить Docker
docker exec docker-client docker version

echo ""
echo "🧪 Создаем тестовый контейнер внутри DinD..."

# Создать тестовый контейнер
docker exec docker-client docker run -d --name test-nginx -p 8080:80 nginx

# Проверить контейнеры
echo "📋 Контейнеры внутри DinD:"
docker exec docker-client docker ps

echo ""
echo "🌐 Веб-интерфейсы:"
echo "   Portainer: http://localhost:9000"
echo "   Test Nginx: http://localhost:8080"

echo ""
echo "✅ Демонстрация запущена!"
echo "   Для остановки: docker-compose down"
echo "   Для подключения к клиенту: docker exec -it docker-client sh"
