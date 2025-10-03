#!/bin/sh

# ===============================================
# ENTRYPOINT ДЛЯ СЕТЕВОГО ДЕМО КОНТЕЙНЕРА
# ===============================================

set -e

echo "🌐 Запуск сетевого демо контейнера..."
echo "Команда: $1"
echo "Контейнер: $(hostname)"
echo "IP адреса:"
ip addr show | grep "inet " | sed 's/^/   /'

case "$1" in
    "web-server")
        echo "🌍 Запуск веб-сервера..."
        
        # Создаем простую HTML страницу
        cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Docker Network Demo - $(hostname)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 10px; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 10px 0; }
        pre { background: #f0f0f0; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Docker Network Demo</h1>
        <div class="info">
            <h3>Информация о контейнере:</h3>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Server:</strong> ${SERVER_NAME:-Unknown}</p>
            <p><strong>Port:</strong> ${SERVER_PORT:-80}</p>
        </div>
        <div class="info">
            <h3>Сетевые интерфейсы:</h3>
            <pre>$(ip addr show)</pre>
        </div>
        <div class="info">
            <h3>Маршруты:</h3>
            <pre>$(ip route)</pre>
        </div>
    </div>
</body>
</html>
EOF

        # Создаем health endpoint
        cat > /var/www/html/health << EOF
{
    "status": "healthy",
    "container": "$(hostname)",
    "server": "${SERVER_NAME:-web-server}",
    "timestamp": "$(date -Iseconds)"
}
EOF

        echo "✅ Веб-сервер готов на порту ${SERVER_PORT:-80}"
        nginx -g "daemon off;"
        ;;
        
    "api-server")
        echo "🔧 Запуск API сервера..."
        
        # Запускаем Python API сервер
        cd /app
        python3 server.py
        ;;
        
    "nginx-lb")
        echo "⚖️  Запуск Load Balancer..."
        
        # Создаем конфигурацию для load balancer
        cat > /etc/nginx/conf.d/default.conf << EOF
upstream backend {
    least_conn;
    server web1:80 max_fails=3 fail_timeout=30s;
    server web2:80 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /health {
        return 200 '{"status":"healthy","service":"load-balancer"}';
        add_header Content-Type application/json;
    }
}
EOF

        nginx -g "daemon off;"
        ;;
        
    "network-monitor")
        echo "📊 Запуск сетевого монитора..."
        
        while true; do
            echo "========== $(date) =========="
            echo "🌐 Активные соединения:"
            netstat -tuln | head -20
            echo ""
            echo "📡 Сетевая статистика:"
            cat /proc/net/dev | head -5
            echo ""
            echo "🔍 DNS запросы:"
            # Мониторим DNS трафик если возможно
            timeout 30 tcpdump -i any -n port 53 2>/dev/null | head -10 || echo "tcpdump недоступен"
            echo ""
            sleep 60
        done
        ;;
        
    "isolated-mode")
        echo "🔒 Запуск в изолированном режиме (без сети)..."
        echo "Этот контейнер не имеет сетевого доступа"
        
        while true; do
            echo "$(date): Работаю в изоляции..."
            echo "Сетевые интерфейсы:"
            ip addr show | grep -E "(lo:|inet )"
            sleep 30
        done
        ;;
        
    "host-mode")
        echo "🏠 Запуск в host режиме..."
        echo "Этот контейнер использует сеть хоста"
        
        echo "Сетевые интерфейсы хоста:"
        ip addr show
        echo ""
        echo "Открытые порты хоста:"
        netstat -tlnp | head -20
        
        # Простой HTTP сервер на хосте
        python3 -m http.server 8888 &
        
        tail -f /dev/null
        ;;
        
    "shared-mode")
        echo "🤝 Запуск в режиме общей сети..."
        echo "Этот контейнер использует сеть другого контейнера"
        
        while true; do
            echo "$(date): Использую сеть контейнера web1"
            echo "Мои сетевые интерфейсы:"
            ip addr show
            echo ""
            sleep 30
        done
        ;;
        
    "multi-service")
        echo "🚀 Запуск множественных сервисов..."
        
        # Запускаем nginx
        nginx &
        
        # Запускаем Python сервер
        cd /app
        python3 server.py &
        
        # Запускаем простой TCP сервер
        nc -l -p 3000 -k -e /app/scripts/test-connectivity.sh &
        
        echo "✅ Все сервисы запущены:"
        echo "   - Nginx: порт 80"
        echo "   - Python API: порт 8080"  
        echo "   - TCP сервер: порт 3000"
        
        # Ожидаем завершения
        wait
        ;;
        
    *)
        echo "❌ Неизвестная команда: $1"
        echo "Доступные команды:"
        echo "  - web-server: веб-сервер на Nginx"
        echo "  - api-server: API сервер на Python"
        echo "  - nginx-lb: Load Balancer"
        echo "  - network-monitor: мониторинг сети"
        echo "  - isolated-mode: изолированный режим"
        echo "  - host-mode: режим хост-сети"
        echo "  - shared-mode: режим общей сети"
        echo "  - multi-service: множественные сервисы"
        exit 1
        ;;
esac
