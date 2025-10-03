#!/bin/sh

# ===============================================
# СКРИПТ ТЕСТИРОВАНИЯ СЕТЕВОЙ СВЯЗНОСТИ
# ===============================================

TARGET_HOST=${1:-"google.com"}
TARGET_PORT=${2:-"80"}

echo "🌐 Тестирование сетевой связности..."
echo "Цель: $TARGET_HOST:$TARGET_PORT"
echo "Контейнер: $(hostname)"
echo "=========================================="

# Информация о сетевых интерфейсах
echo "📡 Сетевые интерфейсы:"
ip addr show | grep -E "(inet |inet6 )" | sed 's/^/   /'

echo ""
echo "🛣️  Таблица маршрутизации:"
ip route | sed 's/^/   /'

echo ""
echo "🔍 DNS конфигурация:"
cat /etc/resolv.conf | sed 's/^/   /'

echo ""
echo "🎯 Тестирование подключения к $TARGET_HOST..."

# Проверка DNS разрешения
if nslookup $TARGET_HOST > /dev/null 2>&1; then
    echo "✅ DNS разрешение работает"
    RESOLVED_IP=$(nslookup $TARGET_HOST | grep "Address:" | tail -n1 | awk '{print $2}')
    echo "   IP адрес: $RESOLVED_IP"
else
    echo "❌ DNS разрешение не работает"
fi

# Проверка ping
echo ""
echo "📡 Ping тест:"
if ping -c 3 -W 3 $TARGET_HOST > /dev/null 2>&1; then
    echo "✅ Ping успешен"
    ping -c 3 $TARGET_HOST | tail -n 2 | sed 's/^/   /'
else
    echo "❌ Ping не прошел"
fi

# Проверка TCP подключения
echo ""
echo "🔌 TCP подключение на порт $TARGET_PORT:"
if nc -z -w 3 $TARGET_HOST $TARGET_PORT; then
    echo "✅ TCP подключение успешно"
else
    echo "❌ TCP подключение не удалось"
fi

# HTTP тест (если порт 80 или 443)
if [ "$TARGET_PORT" = "80" ] || [ "$TARGET_PORT" = "443" ]; then
    echo ""
    echo "🌍 HTTP тест:"
    PROTOCOL="http"
    [ "$TARGET_PORT" = "443" ] && PROTOCOL="https"
    
    if curl -s -m 10 "$PROTOCOL://$TARGET_HOST" > /dev/null; then
        echo "✅ HTTP запрос успешен"
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "$PROTOCOL://$TARGET_HOST")
        echo "   HTTP статус: $HTTP_STATUS"
    else
        echo "❌ HTTP запрос не удался"
    fi
fi

# Проверка портов контейнера
echo ""
echo "🔍 Открытые порты в контейнере:"
netstat -tlnp 2>/dev/null | grep LISTEN | sed 's/^/   /' || echo "   netstat недоступен"

# Проверка переменных окружения
echo ""
echo "🔧 Сетевые переменные окружения:"
env | grep -E "(HOST|PORT|URL|ADDR)" | sed 's/^/   /'

echo ""
echo "=========================================="
echo "Тест завершен"
