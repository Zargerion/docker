#!/bin/bash

# ===============================================
# СКРИПТ РЕЗЕРВНОГО КОПИРОВАНИЯ БАЗ ДАННЫХ
# ===============================================

BACKUP_DIR="/backup"
DATE=$(date +"%Y%m%d_%H%M%S")

echo "💾 Создание резервных копий баз данных..."

# Создаем директорию для бэкапов если её нет
mkdir -p $BACKUP_DIR

# Резервная копия PostgreSQL
echo "📦 Создание бэкапа PostgreSQL..."
su - postgres -c "pg_dump $POSTGRES_DB" > "$BACKUP_DIR/postgres_${POSTGRES_DB}_$DATE.sql"

if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL бэкап создан: postgres_${POSTGRES_DB}_$DATE.sql"
else
    echo "❌ Ошибка создания PostgreSQL бэкапа"
fi

# Резервная копия MySQL
echo "📦 Создание бэкапа MySQL..."
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > "$BACKUP_DIR/mysql_${MYSQL_DATABASE}_$DATE.sql"

if [ $? -eq 0 ]; then
    echo "✅ MySQL бэкап создан: mysql_${MYSQL_DATABASE}_$DATE.sql"
else
    echo "❌ Ошибка создания MySQL бэкапа"
fi

# Резервная копия MongoDB
echo "📦 Создание бэкапа MongoDB..."
mongodump --out "$BACKUP_DIR/mongodb_$DATE"

if [ $? -eq 0 ]; then
    echo "✅ MongoDB бэкап создан: mongodb_$DATE/"
else
    echo "❌ Ошибка создания MongoDB бэкапа"
fi

# Архивирование бэкапов
echo "🗜️  Архивирование бэкапов..."
cd $BACKUP_DIR
tar -czf "full_backup_$DATE.tar.gz" *_$DATE* mongodb_$DATE/

if [ $? -eq 0 ]; then
    echo "✅ Полный архив создан: full_backup_$DATE.tar.gz"
    
    # Удаляем отдельные файлы, оставляем только архив
    rm -f *_$DATE.sql
    rm -rf mongodb_$DATE/
else
    echo "❌ Ошибка создания архива"
fi

# Показываем размер бэкапа
echo "📊 Размер бэкапа:"
ls -lh "$BACKUP_DIR/full_backup_$DATE.tar.gz"

# Очистка старых бэкапов (старше 7 дней)
echo "🧹 Очистка старых бэкапов..."
find $BACKUP_DIR -name "full_backup_*.tar.gz" -mtime +7 -delete

echo "✅ Резервное копирование завершено!"
