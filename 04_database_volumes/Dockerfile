# ===============================================
# РАБОТА С БАЗАМИ ДАННЫХ И VOLUMES В DOCKER
# ===============================================
# Этот пример демонстрирует различные способы работы
# с персистентными данными в Docker

FROM ubuntu:22.04

LABEL description="Демонстрация работы с базами данных и volumes"
LABEL version="1.0.0"

# Предотвращаем интерактивные запросы при установке пакетов
ARG DEBIAN_FRONTEND=noninteractive

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    # PostgreSQL клиент и сервер
    postgresql postgresql-contrib \
    # MySQL клиент и сервер
    mysql-server mysql-client \
    # SQLite
    sqlite3 \
    # MongoDB инструменты
    wget gnupg \
    # Утилиты
    curl \
    nano \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && apt-get update \
    && apt-get install -y mongodb-org \
    && apt-get clean

# Создаем директории для данных различных БД
RUN mkdir -p \
    /var/lib/postgresql/data \
    /var/lib/mysql \
    /var/lib/mongodb \
    /var/lib/sqlite \
    /var/log/databases \
    /backup \
    /scripts

# Устанавливаем Python зависимости для работы с БД
RUN pip3 install \
    psycopg2-binary \
    pymongo \
    mysql-connector-python \
    sqlalchemy

# Копируем скрипты для работы с БД
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Копируем примеры данных
COPY data/ /data/

# Создаем пользователей для БД
RUN useradd -r -s /bin/bash postgres || true
RUN useradd -r -s /bin/bash mysql || true
RUN useradd -r -s /bin/bash mongodb || true

# Настраиваем права доступа к директориям данных
RUN chown -R postgres:postgres /var/lib/postgresql
RUN chown -R mysql:mysql /var/lib/mysql
RUN chown -R mongodb:mongodb /var/lib/mongodb

# VOLUME инструкции для персистентного хранения данных
# Эти директории будут сохраняться между перезапусками контейнера
VOLUME ["/var/lib/postgresql/data"]    # PostgreSQL данные
VOLUME ["/var/lib/mysql"]              # MySQL данные  
VOLUME ["/var/lib/mongodb"]            # MongoDB данные
VOLUME ["/var/lib/sqlite"]             # SQLite файлы
VOLUME ["/backup"]                     # Резервные копии
VOLUME ["/var/log/databases"]          # Логи БД

# Открываем стандартные порты БД
EXPOSE 5432   # PostgreSQL
EXPOSE 3306   # MySQL
EXPOSE 27017  # MongoDB

# Переменные окружения для настройки БД
ENV POSTGRES_DB=testdb
ENV POSTGRES_USER=testuser
ENV POSTGRES_PASSWORD=testpass
ENV MYSQL_ROOT_PASSWORD=rootpass
ENV MYSQL_DATABASE=testdb
ENV MYSQL_USER=testuser
ENV MYSQL_PASSWORD=testpass

# Копируем основной скрипт запуска
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Healthcheck для проверки работоспособности БД
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /scripts/healthcheck.sh

# Точка входа
ENTRYPOINT ["/entrypoint.sh"]

# Команда по умолчанию - запуск всех БД
CMD ["start-all"]

# ===============================================
# КОМАНДЫ ДЛЯ РАБОТЫ С VOLUMES:
# ===============================================
#
# Создание именованного volume:
# docker volume create postgres_data
# docker volume create mysql_data
# docker volume create mongo_data
#
# Запуск с именованными volumes:
# docker run -d --name db-container \
#   -v postgres_data:/var/lib/postgresql/data \
#   -v mysql_data:/var/lib/mysql \
#   -v mongo_data:/var/lib/mongodb \
#   -p 5432:5432 -p 3306:3306 -p 27017:27017 \
#   database-volumes
#
# Запуск с bind mounts (локальные директории):
# docker run -d --name db-container \
#   -v ${PWD}/postgres-data:/var/lib/postgresql/data \
#   -v ${PWD}/mysql-data:/var/lib/mysql \
#   -v ${PWD}/mongo-data:/var/lib/mongodb \
#   -v ${PWD}/backups:/backup \
#   database-volumes
#
# Создание резервной копии:
# docker exec db-container /scripts/backup.sh
#
# Восстановление из резервной копии:
# docker exec db-container /scripts/restore.sh backup-file.sql
#
# Просмотр volumes:
# docker volume ls
# docker volume inspect postgres_data
#
# Копирование данных между контейнерами:
# docker run --rm -v postgres_data:/source -v backup_volume:/backup \
#   ubuntu tar czf /backup/postgres-backup.tar.gz -C /source .
#
# Очистка volumes:
# docker volume prune
# docker volume rm postgres_data mysql_data mongo_data
