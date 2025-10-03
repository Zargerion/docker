#!/bin/bash

# ===============================================
# HEALTHCHECK СКРИПТ ДЛЯ БАЗ ДАННЫХ
# ===============================================

echo "🏥 Проверка состояния баз данных..."

EXIT_CODE=0

# Проверка PostgreSQL
if pgrep -x "postgres" > /dev/null; then
    if su - postgres -c "pg_isready -q"; then
        echo "✅ PostgreSQL: работает"
    else
        echo "❌ PostgreSQL: недоступен"
        EXIT_CODE=1
    fi
else
    echo "⚠️  PostgreSQL: не запущен"
fi

# Проверка MySQL
if pgrep -x "mysqld" > /dev/null; then
    if mysqladmin -u $MYSQL_USER -p$MYSQL_PASSWORD ping --silent; then
        echo "✅ MySQL: работает"
    else
        echo "❌ MySQL: недоступен"
        EXIT_CODE=1
    fi
else
    echo "⚠️  MySQL: не запущен"
fi

# Проверка MongoDB
if pgrep -x "mongod" > /dev/null; then
    if mongo --eval "db.adminCommand('ismaster')" --quiet > /dev/null 2>&1; then
        echo "✅ MongoDB: работает"
    else
        echo "❌ MongoDB: недоступен"
        EXIT_CODE=1
    fi
else
    echo "⚠️  MongoDB: не запущен"
fi

# Проверка доступности volumes
echo "📁 Проверка volumes:"
for dir in "/var/lib/postgresql/data" "/var/lib/mysql" "/var/lib/mongodb" "/backup"; do
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        echo "✅ $dir: доступен"
    else
        echo "❌ $dir: недоступен"
        EXIT_CODE=1
    fi
done

# Проверка свободного места
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    echo "⚠️  Диск заполнен на $DISK_USAGE%"
    EXIT_CODE=1
else
    echo "✅ Свободное место: $((100-DISK_USAGE))%"
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "🎉 Все проверки пройдены успешно!"
else
    echo "💥 Обнаружены проблемы!"
fi

exit $EXIT_CODE
