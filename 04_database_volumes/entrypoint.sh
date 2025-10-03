#!/bin/bash

# ===============================================
# ENTRYPOINT ДЛЯ КОНТЕЙНЕРА С БАЗАМИ ДАННЫХ
# ===============================================

set -e

echo "🗄️  Запуск контейнера с базами данных..."

# Функция инициализации PostgreSQL
init_postgres() {
    echo "🐘 Инициализация PostgreSQL..."
    
    if [ ! -d "/var/lib/postgresql/data/base" ]; then
        echo "   Создание нового кластера PostgreSQL..."
        su - postgres -c "/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/data"
        
        # Запускаем PostgreSQL для настройки
        su - postgres -c "/usr/lib/postgresql/14/bin/pg_ctl -D /var/lib/postgresql/data -l /var/log/databases/postgresql.log start"
        
        sleep 5
        
        # Создаем пользователя и базу данных
        su - postgres -c "createuser -s $POSTGRES_USER"
        su - postgres -c "createdb -O $POSTGRES_USER $POSTGRES_DB"
        su - postgres -c "psql -c \"ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';\""
        
        echo "✅ PostgreSQL инициализирован"
    else
        echo "   PostgreSQL уже инициализирован"
        su - postgres -c "/usr/lib/postgresql/14/bin/pg_ctl -D /var/lib/postgresql/data -l /var/log/databases/postgresql.log start"
    fi
}

# Функция инициализации MySQL
init_mysql() {
    echo "🐬 Инициализация MySQL..."
    
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "   Создание новой БД MySQL..."
        mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
        
        # Запускаем MySQL
        mysqld --user=mysql --datadir=/var/lib/mysql --pid-file=/var/run/mysqld/mysqld.pid &
        MYSQL_PID=$!
        
        sleep 10
        
        # Настраиваем root пароль и создаем пользователя
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
        
        echo "✅ MySQL инициализирован"
    else
        echo "   MySQL уже инициализирован"
        mysqld --user=mysql --datadir=/var/lib/mysql --pid-file=/var/run/mysqld/mysqld.pid &
    fi
}

# Функция инициализации MongoDB
init_mongodb() {
    echo "🍃 Инициализация MongoDB..."
    
    # Создаем директории для MongoDB
    mkdir -p /var/lib/mongodb/data /var/log/mongodb
    chown -R mongodb:mongodb /var/lib/mongodb /var/log/mongodb
    
    # Запускаем MongoDB
    su - mongodb -c "mongod --dbpath /var/lib/mongodb/data --logpath /var/log/mongodb/mongodb.log --fork"
    
    sleep 5
    
    echo "✅ MongoDB запущен"
}

# Функция для создания тестовых данных
create_test_data() {
    echo "📊 Создание тестовых данных..."
    
    # PostgreSQL тестовые данные
    su - postgres -c "psql -d $POSTGRES_DB -c \"
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        INSERT INTO users (name, email) VALUES 
        ('Алексей Иванов', 'alexey@example.com'),
        ('Мария Петрова', 'maria@example.com'),
        ('Дмитрий Сидоров', 'dmitry@example.com')
        ON CONFLICT DO NOTHING;
    \""
    
    # MySQL тестовые данные
    mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE -e "
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            price DECIMAL(10,2),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        INSERT IGNORE INTO products (id, name, price) VALUES 
        (1, 'Ноутбук', 50000.00),
        (2, 'Мышь', 1500.00),
        (3, 'Клавиатура', 3000.00);
    "
    
    # MongoDB тестовые данные
    mongo --eval "
        use testdb;
        db.orders.insertMany([
            {orderId: 1, product: 'Ноутбук', quantity: 1, status: 'delivered'},
            {orderId: 2, product: 'Мышь', quantity: 2, status: 'pending'},
            {orderId: 3, product: 'Клавиатура', quantity: 1, status: 'shipped'}
        ], {ordered: false});
    "
    
    echo "✅ Тестовые данные созданы"
}

# Основная логика
case "$1" in
    "start-all")
        init_postgres
        init_mysql
        init_mongodb
        create_test_data
        echo "🚀 Все базы данных запущены и готовы к работе!"
        ;;
    "postgres-only")
        init_postgres
        create_test_data
        echo "🐘 Только PostgreSQL запущен"
        ;;
    "mysql-only")
        init_mysql
        create_test_data
        echo "🐬 Только MySQL запущен"
        ;;
    "mongo-only")
        init_mongodb
        create_test_data
        echo "🍃 Только MongoDB запущен"
        ;;
    *)
        echo "Использование: $0 {start-all|postgres-only|mysql-only|mongo-only}"
        exit 1
        ;;
esac

# Бесконечный цикл для поддержания контейнера в рабочем состоянии
echo "📡 Контейнер готов к работе. Нажмите Ctrl+C для остановки."
tail -f /var/log/databases/postgresql.log 2>/dev/null || tail -f /dev/null
