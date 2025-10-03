#!/bin/sh

# Скрипт запуска для многоэтапного контейнера
echo "Запуск многосервисного контейнера..."

# Запускаем Go сервис в фоне
echo "Запуск Go API сервиса..."
/usr/local/bin/go-service &
GO_PID=$!

# Запускаем Nginx
echo "Запуск Nginx веб-сервера..."
nginx -g "daemon off;" &
NGINX_PID=$!

# Функция для корректного завершения процессов
cleanup() {
    echo "Получен сигнал завершения, останавливаем сервисы..."
    kill $GO_PID 2>/dev/null
    kill $NGINX_PID 2>/dev/null
    wait $GO_PID 2>/dev/null
    wait $NGINX_PID 2>/dev/null
    echo "Все сервисы остановлены"
    exit 0
}

# Устанавливаем обработчики сигналов
trap cleanup TERM INT

echo "Все сервисы запущены:"
echo "- Nginx веб-сервер на порту 80"
echo "- Go API сервис на порту 8080"

# Ждем завершения любого из процессов
wait
