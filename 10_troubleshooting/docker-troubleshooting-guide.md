# 🔧 Руководство по устранению проблем Docker

Этот документ содержит решения наиболее распространенных проблем при работе с Docker, а также инструменты и методы для диагностики и отладки.

## 📋 Содержание

1. [Проблемы с установкой и настройкой](#проблемы-с-установкой-и-настройкой)
2. [Проблемы со сборкой образов](#проблемы-со-сборкой-образов)
3. [Проблемы с запуском контейнеров](#проблемы-с-запуском-контейнеров)
4. [Сетевые проблемы](#сетевые-проблемы)
5. [Проблемы с volumes и хранением](#проблемы-с-volumes-и-хранением)
6. [Проблемы производительности](#проблемы-производительности)
7. [Проблемы с Docker Compose](#проблемы-с-docker-compose)
8. [Проблемы безопасности](#проблемы-безопасности)
9. [Инструменты диагностики](#инструменты-диагностики)
10. [Общие советы по отладке](#общие-советы-по-отладке)

## 🛠️ Проблемы с установкой и настройкой

### Docker не запускается

**Проблема:** Docker daemon не запускается
```bash
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Решения:**
```bash
# Проверка статуса Docker
sudo systemctl status docker

# Запуск Docker
sudo systemctl start docker
sudo systemctl enable docker

# Проверка прав пользователя
sudo usermod -aG docker $USER
# Перелогиньтесь после добавления в группу

# Проверка socket файла
ls -la /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock
```

### Недостаточно места на диске

**Проблема:** "No space left on device"

**Решения:**
```bash
# Проверка использования места
docker system df
df -h

# Очистка неиспользуемых ресурсов
docker system prune -a -f

# Очистка по типам
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f

# Изменение директории Docker
sudo systemctl stop docker
sudo mv /var/lib/docker /new/path/docker
sudo ln -s /new/path/docker /var/lib/docker
sudo systemctl start docker
```

### Проблемы с правами доступа

**Проблема:** Permission denied при работе с Docker

**Решения:**
```bash
# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Проверка групп пользователя
groups $USER

# Временное решение (не рекомендуется)
sudo chmod 666 /var/run/docker.sock
```

## 🐳 Проблемы со сборкой образов

### Ошибки при сборке

**Проблема:** "COPY failed: no source files were specified"
```dockerfile
COPY . /app
```

**Решения:**
```bash
# Проверка .dockerignore
cat .dockerignore

# Проверка контекста сборки
ls -la

# Сборка с подробным выводом
docker build --progress=plain --no-cache .

# Проверка синтаксиса Dockerfile
hadolint Dockerfile
```

### Проблемы с кэшированием

**Проблема:** Слои не кэшируются должным образом

**Решения:**
```bash
# Принудительная пересборка без кэша
docker build --no-cache .

# Проверка истории слоев
docker history myimage:latest

# Оптимизация порядка инструкций
# Поместите часто изменяющиеся файлы в конец Dockerfile
```

### Медленная сборка

**Проблема:** Сборка занимает слишком много времени

**Решения:**
```bash
# Использование BuildKit
export DOCKER_BUILDKIT=1
docker build .

# Многоэтапная сборка
# FROM node:16 AS builder
# ...
# FROM node:16-alpine AS production

# Оптимизация .dockerignore
echo "node_modules" >> .dockerignore
echo ".git" >> .dockerignore

# Параллельная сборка с buildx
docker buildx build --platform linux/amd64,linux/arm64 .
```

### Ошибки с зависимостями

**Проблема:** Package not found или dependency conflicts

**Решения:**
```dockerfile
# Обновление индекса пакетов
RUN apt-get update && apt-get install -y package

# Фиксация версий
RUN apt-get update && apt-get install -y \
    package1=1.2.3 \
    package2=2.3.4

# Очистка кэша
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

## 🚀 Проблемы с запуском контейнеров

### Контейнер сразу останавливается

**Проблема:** Контейнер завершается с кодом 0 или 1

**Диагностика:**
```bash
# Просмотр логов
docker logs container_name

# Запуск в интерактивном режиме
docker run -it myimage /bin/bash

# Проверка процессов
docker top container_name

# Проверка кода выхода
docker inspect container_name --format='{{.State.ExitCode}}'
```

**Решения:**
```dockerfile
# Убедитесь, что CMD/ENTRYPOINT запускает долгоживущий процесс
CMD ["python", "app.py"]  # не CMD ["python", "-c", "print('hello')"]

# Используйте exec форму команд
CMD ["nginx", "-g", "daemon off;"]  # не CMD nginx -g "daemon off;"
```

### Проблемы с портами

**Проблема:** Порт недоступен или уже используется

**Диагностика:**
```bash
# Проверка открытых портов
docker port container_name
netstat -tlnp | grep :8080

# Проверка процессов на порту
lsof -i :8080
sudo ss -tlnp | grep :8080
```

**Решения:**
```bash
# Использование другого порта
docker run -p 8081:80 nginx

# Остановка процесса, занимающего порт
sudo kill -9 $(lsof -t -i:8080)

# Проверка доступности порта в контейнере
docker exec container_name netstat -tlnp
```

### Проблемы с переменными окружения

**Проблема:** Переменные окружения не передаются или неправильно обрабатываются

**Диагностика:**
```bash
# Проверка переменных в контейнере
docker exec container_name env

# Проверка в процессе запуска
docker run --rm myimage env
```

**Решения:**
```bash
# Правильная передача переменных
docker run -e VAR1=value1 -e VAR2=value2 myimage

# Использование файла с переменными
docker run --env-file .env myimage

# В Dockerfile
ENV NODE_ENV=production
```

### Проблемы с файловой системой

**Проблема:** Read-only file system или permission denied

**Решения:**
```bash
# Проверка прав доступа
docker exec container_name ls -la /app

# Запуск с правильным пользователем
docker run -u $(id -u):$(id -g) myimage

# Изменение владельца в Dockerfile
RUN chown -R appuser:appuser /app
USER appuser
```

## 🌐 Сетевые проблемы

### Контейнеры не могут связаться друг с другом

**Проблема:** Connection refused между контейнерами

**Диагностика:**
```bash
# Проверка сетей
docker network ls
docker network inspect bridge

# Проверка IP адресов контейнеров
docker inspect container1 --format='{{.NetworkSettings.IPAddress}}'

# Тест связности
docker exec container1 ping container2
docker exec container1 nslookup container2
```

**Решения:**
```bash
# Создание пользовательской сети
docker network create mynetwork
docker run --network mynetwork --name app1 myimage
docker run --network mynetwork --name app2 myimage

# Использование имен контейнеров вместо IP
curl http://container2:8080/api

# Проверка портов в контейнере
docker exec container2 netstat -tlnp
```

### DNS не работает

**Проблема:** Cannot resolve hostname

**Решения:**
```bash
# Проверка DNS настроек
docker exec container_name cat /etc/resolv.conf

# Настройка DNS серверов
docker run --dns=8.8.8.8 --dns=8.8.4.4 myimage

# Добавление записей в hosts
docker run --add-host myhost:192.168.1.100 myimage
```

### Проблемы с портами в Docker Compose

**Проблема:** Порты не доступны извне

**Решения:**
```yaml
# Правильное объявление портов
services:
  web:
    ports:
      - "8080:80"  # host:container
    expose:
      - "80"       # только для других контейнеров
```

## 💾 Проблемы с volumes и хранением

### Данные не сохраняются

**Проблема:** Данные теряются при перезапуске контейнера

**Решения:**
```bash
# Использование именованных volumes
docker volume create mydata
docker run -v mydata:/app/data myimage

# Проверка точек монтирования
docker inspect container_name --format='{{.Mounts}}'

# Bind mount для разработки
docker run -v $(pwd):/app myimage
```

### Проблемы с правами доступа к volumes

**Проблема:** Permission denied при записи в volume

**Решения:**
```bash
# Проверка владельца volume
docker exec container_name ls -la /app/data

# Создание volume с правильными правами
docker run -v myvolume:/app/data --user $(id -u):$(id -g) myimage

# В Dockerfile
RUN mkdir -p /app/data && chown appuser:appuser /app/data
```

### Volume не монтируется

**Проблема:** Bind mount не работает

**Диагностика:**
```bash
# Проверка путей
docker inspect container_name --format='{{.Mounts}}'

# Проверка SELinux (если используется)
ls -Z /host/path
```

**Решения:**
```bash
# Использование абсолютных путей
docker run -v /absolute/path:/container/path myimage

# SELinux контекст
docker run -v /host/path:/container/path:Z myimage

# Проверка прав на хосте
chmod 755 /host/path
```

## ⚡ Проблемы производительности

### Высокое использование CPU

**Диагностика:**
```bash
# Мониторинг ресурсов
docker stats
htop

# Профилирование приложения в контейнере
docker exec container_name top
docker exec container_name ps aux
```

**Решения:**
```bash
# Ограничение CPU
docker run --cpus="1.5" myimage
docker run --cpu-shares=512 myimage

# В Docker Compose
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
```

### Высокое использование памяти

**Диагностика:**
```bash
# Проверка использования памяти
docker stats --no-stream
docker exec container_name free -h
```

**Решения:**
```bash
# Ограничение памяти
docker run -m 512m myimage
docker run --memory=1g --memory-swap=2g myimage

# Мониторинг утечек памяти
docker exec container_name ps aux --sort=-%mem
```

### Медленная работа I/O

**Решения:**
```bash
# Использование tmpfs для временных файлов
docker run --tmpfs /tmp:rw,noexec,nosuid,size=100m myimage

# Оптимизация Docker storage driver
# В /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
```

## 🐙 Проблемы с Docker Compose

### Сервисы не запускаются

**Проблема:** "Service failed to build" или "Service unhealthy"

**Диагностика:**
```bash
# Проверка конфигурации
docker-compose config
docker-compose config --quiet

# Подробные логи
docker-compose up --verbose
docker-compose logs service_name
```

**Решения:**
```bash
# Пересборка образов
docker-compose build --no-cache
docker-compose up --build

# Проверка зависимостей
# В docker-compose.yml
services:
  app:
    depends_on:
      db:
        condition: service_healthy
```

### Проблемы с переменными окружения

**Проблема:** Переменные не подставляются

**Решения:**
```bash
# Проверка файла .env
cat .env

# Использование переменных по умолчанию
environment:
  - DATABASE_URL=${DATABASE_URL:-postgresql://localhost/db}

# Проверка подстановки
docker-compose config | grep DATABASE_URL
```

### Конфликты портов

**Проблема:** Port already in use

**Решения:**
```bash
# Поиск процесса на порту
sudo lsof -i :8080

# Изменение портов в compose файле
ports:
  - "8081:80"

# Остановка конфликтующих сервисов
docker-compose down
sudo systemctl stop apache2
```

## 🔒 Проблемы безопасности

### Контейнер запускается от root

**Проблема:** Security risk при запуске от root

**Решения:**
```dockerfile
# Создание пользователя в Dockerfile
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Или при запуске
docker run -u 1000:1000 myimage
```

### Уязвимости в образах

**Диагностика:**
```bash
# Сканирование на уязвимости
trivy image myimage:latest
docker scout cves myimage:latest
```

**Решения:**
```bash
# Обновление базового образа
FROM node:18.17.1-alpine3.18  # конкретная версия

# Регулярное обновление зависимостей
RUN apk update && apk upgrade
```

## 🔍 Инструменты диагностики

### Основные команды диагностики

```bash
# Системная информация
docker info
docker version
docker system df

# Статус контейнеров
docker ps -a
docker stats

# Детальная информация
docker inspect container_name
docker logs --details container_name

# Сетевая диагностика
docker network ls
docker network inspect network_name

# Анализ образов
docker images
docker history image_name
```

### Полезные инструменты

```bash
# Анализ размера образа
dive myimage:latest

# Линтинг Dockerfile
hadolint Dockerfile

# Сканирование безопасности
trivy image myimage:latest
grype myimage:latest

# Мониторинг
docker stats
ctop  # docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest
```

### Отладочные контейнеры

```bash
# Отладочный контейнер с инструментами
docker run -it --rm \
  --name debug \
  --network container:target_container \
  --pid container:target_container \
  nicolaka/netshoot

# Контейнер для анализа сети
docker run -it --rm --net host nicolaka/netshoot

# Контейнер с системными инструментами
docker run -it --rm --pid host --privileged ubuntu:latest
```

## 💡 Общие советы по отладке

### Методика поиска проблем

1. **Воспроизведите проблему** - убедитесь, что можете стабильно воспроизвести ошибку
2. **Соберите информацию** - логи, статистика, конфигурации
3. **Изолируйте проблему** - определите, где именно возникает ошибка
4. **Проверьте основы** - сеть, диск, память, права доступа
5. **Используйте инструменты** - docker inspect, logs, stats
6. **Тестируйте по частям** - запускайте компоненты отдельно

### Чек-лист для диагностики

- [ ] Проверены логи контейнера (`docker logs`)
- [ ] Проверено состояние контейнера (`docker ps -a`)
- [ ] Проверены ресурсы системы (`docker stats`, `df -h`)
- [ ] Проверена сетевая связность (`ping`, `curl`)
- [ ] Проверены переменные окружения (`docker exec env`)
- [ ] Проверены права доступа к файлам (`ls -la`)
- [ ] Проверена конфигурация (`docker inspect`)
- [ ] Проверены volumes и мounts
- [ ] Проверены порты и их доступность
- [ ] Проверены зависимости между сервисами

### Полезные алиасы для отладки

```bash
# Добавьте в .bashrc или .zshrc
alias dlog='docker logs -f'
alias dps='docker ps -a'
alias dstats='docker stats --no-stream'
alias dinspect='docker inspect'
alias dexec='docker exec -it'

# Функция для быстрого подключения к контейнеру
dsh() {
    docker exec -it $1 /bin/bash || docker exec -it $1 /bin/sh
}

# Функция для просмотра логов с временными метками
dlogts() {
    docker logs -t -f $1
}
```

---

Помните: большинство проблем с Docker связаны с неправильной конфигурацией, сетевыми настройками или правами доступа. Систематический подход к диагностике поможет быстро найти и устранить проблему.
