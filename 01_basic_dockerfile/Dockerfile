# ===============================================
# БАЗОВЫЙ DOCKERFILE С ОБЪЯСНЕНИЕМ ВСЕХ КОМАНД
# ===============================================

# FROM - указывает базовый образ, от которого наследуется наш образ
# Всегда должна быть первой инструкцией (кроме комментариев и ARG до FROM)
FROM ubuntu:22.04

# LABEL - добавляет метаданные к образу в формате ключ-значение
# Полезно для версионирования, описания и контактной информации
LABEL maintainer="developer@example.com"
LABEL version="1.0"
LABEL description="Базовый пример Dockerfile с объяснениями"

# ARG - определяет переменные времени сборки
# Эти переменные можно передать через --build-arg при сборке
ARG DEBIAN_FRONTEND=noninteractive
ARG APP_VERSION=1.0.0

# ENV - устанавливает переменные окружения, которые будут доступны во время выполнения контейнера
# В отличие от ARG, эти переменные сохраняются в готовом образе
ENV APP_HOME=/app
ENV NODE_VERSION=18
ENV PATH=$PATH:/app/bin

# WORKDIR - устанавливает рабочую директорию для последующих инструкций
# Если директория не существует, она будет создана
WORKDIR $APP_HOME

# RUN - выполняет команды в новом слое поверх текущего образа
# Результат выполнения сохраняется в образе
# Лучшая практика: объединять команды через && для уменьшения количества слоев
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim \
        git \
        python3 \
        python3-pip \
        nodejs \
        npm && \
    # Очистка кэша пакетного менеджера для уменьшения размера образа
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# COPY - копирует файлы/директории с хоста в образ
# Синтаксис: COPY <источник> <назначение>
# Источник относительно контекста сборки (обычно директория с Dockerfile)
COPY requirements.txt .
COPY src/ ./src/
COPY config/ ./config/

# ADD - похожа на COPY, но с дополнительными возможностями:
# - может распаковывать tar архивы
# - может скачивать файлы по URL
# Рекомендуется использовать COPY, если не нужны дополнительные возможности ADD
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-it.sh

# RUN для установки зависимостей Python
RUN pip3 install --no-cache-dir -r requirements.txt

# EXPOSE - документирует, какие порты планируется использовать
# НЕ публикует порты автоматически - это делается при запуске контейнера
# Служит документацией и используется docker-compose
EXPOSE 8080
EXPOSE 3000

# VOLUME - создает точку монтирования для внешних томов
# Данные в этих директориях сохраняются между перезапусками контейнера
VOLUME ["/app/data", "/app/logs"]

# USER - указывает пользователя для выполнения последующих инструкций
# Лучшая практика безопасности - не запускать приложения от root
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser $APP_HOME
USER appuser

# HEALTHCHECK - определяет команду для проверки здоровья контейнера
# Docker будет периодически выполнять эту команду
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# ONBUILD - добавляет триггер, который выполнится при использовании этого образа как базового
# Полезно для создания базовых образов для разработки
ONBUILD COPY . /app/
ONBUILD RUN pip3 install -r requirements.txt

# STOPSIGNAL - указывает сигнал, который будет отправлен контейнеру для остановки
# По умолчанию SIGTERM
STOPSIGNAL SIGTERM

# SHELL - позволяет переопределить оболочку по умолчанию для RUN, CMD и ENTRYPOINT
# По умолчанию ["/bin/sh", "-c"] на Linux
SHELL ["/bin/bash", "-c"]

# CMD - указывает команду по умолчанию для выполнения при запуске контейнера
# Может быть переопределена аргументами docker run
# Должна быть только одна инструкция CMD в Dockerfile
CMD ["python3", "-m", "http.server", "8080"]

# ENTRYPOINT - указывает команду, которая всегда будет выполняться
# Аргументы docker run будут переданы как параметры ENTRYPOINT
# Если указаны и ENTRYPOINT, и CMD, то CMD становится аргументами по умолчанию для ENTRYPOINT
# ENTRYPOINT ["python3", "app.py"]

# ===============================================
# КОМАНДЫ ДЛЯ СБОРКИ И ЗАПУСКА:
# ===============================================
# 
# Сборка образа:
# docker build -t basic-example .
#
# Сборка с аргументами:
# docker build --build-arg APP_VERSION=2.0.0 -t basic-example:2.0 .
#
# Запуск контейнера:
# docker run -d -p 8080:8080 --name basic-container basic-example
#
# Запуск с интерактивным режимом:
# docker run -it --rm basic-example /bin/bash
#
# Запуск с монтированием томов:
# docker run -d -p 8080:8080 -v ${PWD}/data:/app/data basic-example
#
# Просмотр логов:
# docker logs basic-container
#
# Остановка и удаление:
# docker stop basic-container
# docker rm basic-container
# docker rmi basic-example
