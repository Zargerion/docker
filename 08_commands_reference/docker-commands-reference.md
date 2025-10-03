# 🐳 Полный справочник Docker команд

Этот справочник содержит все основные команды Docker с подробными примерами и объяснениями.

## 📋 Содержание

1. [Основы Docker](#основы-docker)
2. [Работа с образами](#работа-с-образами)
3. [Работа с контейнерами](#работа-с-контейнерами)
4. [Volumes и хранение данных](#volumes-и-хранение-данных)
5. [Сети](#сети)
6. [Docker Compose](#docker-compose)
7. [Docker Swarm](#docker-swarm)
8. [Безопасность](#безопасность)
9. [Мониторинг и отладка](#мониторинг-и-отладка)
10. [Оптимизация](#оптимизация)

## 🚀 Основы Docker

### Информация о системе
```bash
# Версия Docker
docker version
docker --version

# Информация о системе Docker
docker info
docker system info

# Использование дискового пространства
docker system df
docker system df -v  # подробная информация

# События Docker в реальном времени
docker events
docker events --filter container=mycontainer
docker events --since="2023-01-01" --until="2023-12-31"
```

### Справка по командам
```bash
# Общая справка
docker --help
docker help

# Справка по конкретной команде
docker run --help
docker build --help
docker-compose --help
```

## 🖼️ Работа с образами

### Поиск и получение образов
```bash
# Поиск образов в Docker Hub
docker search nginx
docker search --limit=10 --filter=stars=100 nginx

# Скачивание образа
docker pull nginx
docker pull nginx:alpine
docker pull nginx:1.21.6

# Скачивание всех тегов образа
docker pull --all-tags nginx

# Скачивание с определенной архитектуры
docker pull --platform linux/arm64 nginx
```

### Просмотр образов
```bash
# Список локальных образов
docker images
docker image ls
docker images --all  # включая промежуточные слои

# Фильтрация образов
docker images --filter "dangling=true"  # висячие образы
docker images --filter "label=maintainer=nginx"
docker images --filter "before=nginx:latest"
docker images --filter "since=ubuntu:20.04"

# Форматированный вывод
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
docker images --format "{{.Repository}}:{{.Tag}} -> {{.Size}}"

# Размеры образов
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" --sort size
```

### Информация об образах
```bash
# Детальная информация об образе
docker inspect nginx
docker inspect nginx:alpine

# История слоев образа
docker history nginx
docker history --no-trunc nginx  # полная информация

# Анализ слоев
docker image inspect nginx --format='{{.RootFS.Layers}}'
```

### Сборка образов
```bash
# Базовая сборка
docker build .
docker build -t myapp .
docker build -t myapp:v1.0 .

# Сборка с аргументами
docker build --build-arg VERSION=1.0 -t myapp .
docker build --build-arg HTTP_PROXY=http://proxy:8080 .

# Сборка с кэшированием
docker build --cache-from myapp:latest -t myapp:v1.1 .
docker build --no-cache -t myapp .

# Сборка с различными контекстами
docker build -f Dockerfile.prod -t myapp:prod .
docker build https://github.com/user/repo.git#main
docker build - < Dockerfile

# Сборка с BuildKit
DOCKER_BUILDKIT=1 docker build .
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .

# Сборка с секретами (BuildKit)
echo "secret_value" | docker build --secret id=mysecret,src=- .
docker build --secret id=ssh,src=$HOME/.ssh/id_rsa .

# Сборка с выводом метаданных
docker build --metadata-file metadata.json .
```

### Тегирование и публикация
```bash
# Создание тега
docker tag myapp:latest myregistry.com/myapp:latest
docker tag myapp:latest myapp:v1.0

# Публикация образа
docker push myregistry.com/myapp:latest
docker push --all-tags myregistry.com/myapp

# Вход в реестр
docker login
docker login myregistry.com
docker login -u username -p password myregistry.com

# Выход из реестра
docker logout
docker logout myregistry.com
```

### Управление образами
```bash
# Удаление образов
docker rmi nginx
docker rmi nginx:alpine
docker image rm nginx

# Принудительное удаление
docker rmi -f nginx

# Удаление по ID
docker rmi 4bb46517cac3

# Удаление всех образов
docker rmi $(docker images -q)

# Удаление висячих образов
docker image prune
docker image prune -f  # без подтверждения

# Удаление неиспользуемых образов
docker image prune -a
docker image prune --filter "until=24h"

# Экспорт и импорт образов
docker save nginx > nginx.tar
docker save -o nginx.tar nginx
docker load < nginx.tar
docker load -i nginx.tar

# Экспорт в сжатом виде
docker save nginx | gzip > nginx.tar.gz
gunzip -c nginx.tar.gz | docker load
```

## 📦 Работа с контейнерами

### Создание и запуск контейнеров
```bash
# Базовый запуск
docker run nginx
docker run -d nginx  # в фоновом режиме
docker run -it ubuntu bash  # интерактивный режим

# Именование контейнеров
docker run --name mycontainer nginx
docker run --name web-server -d nginx

# Проброс портов
docker run -p 8080:80 nginx  # хост:контейнер
docker run -p 127.0.0.1:8080:80 nginx  # привязка к IP
docker run -P nginx  # автоматический проброс всех портов

# Переменные окружения
docker run -e NODE_ENV=production myapp
docker run -e DATABASE_URL=postgres://... myapp
docker run --env-file .env myapp

# Монтирование volumes
docker run -v /host/path:/container/path nginx
docker run -v myvolume:/app/data nginx
docker run --mount type=bind,source=/host,target=/container nginx

# Ограничение ресурсов
docker run -m 512m nginx  # ограничение памяти
docker run --cpus="1.5" nginx  # ограничение CPU
docker run --memory=1g --cpus="2" nginx

# Сетевые настройки
docker run --network mynetwork nginx
docker run --network=host nginx
docker run --network=none nginx

# Рабочая директория и пользователь
docker run -w /app myapp
docker run -u 1000:1000 myapp
docker run --user $(id -u):$(id -g) myapp

# Политика перезапуска
docker run --restart=always nginx
docker run --restart=unless-stopped nginx
docker run --restart=on-failure:3 nginx

# Удаление после остановки
docker run --rm nginx
docker run -it --rm ubuntu bash

# Hostname и DNS
docker run --hostname myserver nginx
docker run --add-host myhost:192.168.1.100 nginx
docker run --dns=8.8.8.8 nginx

# Capabilities и привилегии
docker run --privileged nginx
docker run --cap-add=NET_ADMIN nginx
docker run --cap-drop=ALL nginx

# Лимиты файловой системы
docker run --read-only nginx
docker run --tmpfs /tmp nginx
```

### Управление контейнерами
```bash
# Список контейнеров
docker ps  # запущенные
docker ps -a  # все контейнеры
docker container ls
docker container ls -a

# Фильтрация контейнеров
docker ps --filter "status=running"
docker ps --filter "name=web"
docker ps --filter "ancestor=nginx"
docker ps --filter "label=env=production"

# Форматированный вывод
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --format "{{.Names}} -> {{.Status}}"

# Управление состоянием
docker start mycontainer
docker stop mycontainer
docker restart mycontainer
docker pause mycontainer
docker unpause mycontainer

# Остановка с таймаутом
docker stop -t 30 mycontainer

# Принудительная остановка
docker kill mycontainer
docker kill -s SIGKILL mycontainer

# Удаление контейнеров
docker rm mycontainer
docker rm -f mycontainer  # принудительно
docker container rm mycontainer

# Удаление всех остановленных контейнеров
docker container prune
docker rm $(docker ps -a -q -f status=exited)

# Переименование
docker rename oldname newname
```

### Взаимодействие с контейнерами
```bash
# Выполнение команд в контейнере
docker exec mycontainer ls -la
docker exec -it mycontainer bash
docker exec -it mycontainer /bin/sh

# Выполнение от другого пользователя
docker exec -u root mycontainer whoami
docker exec -u 1000 mycontainer id

# Выполнение с переменными окружения
docker exec -e VAR=value mycontainer env

# Копирование файлов
docker cp mycontainer:/app/file.txt ./file.txt
docker cp ./file.txt mycontainer:/app/
docker cp . mycontainer:/app/  # копирование директории

# Просмотр логов
docker logs mycontainer
docker logs -f mycontainer  # следить за логами
docker logs --tail 100 mycontainer
docker logs --since="2023-01-01" mycontainer
docker logs --until="2023-12-31" mycontainer

# Статистика использования ресурсов
docker stats
docker stats mycontainer
docker stats --no-stream  # одноразовый вывод

# Информация о контейнере
docker inspect mycontainer
docker inspect --format='{{.State.Status}}' mycontainer
docker inspect --format='{{.NetworkSettings.IPAddress}}' mycontainer

# Процессы в контейнере
docker top mycontainer
docker top mycontainer aux

# Изменения в файловой системе
docker diff mycontainer

# Экспорт контейнера
docker export mycontainer > container.tar
docker export -o container.tar mycontainer

# Импорт как образ
docker import container.tar myimage:tag
cat container.tar | docker import - myimage:tag

# Создание образа из контейнера
docker commit mycontainer mynewimage:tag
docker commit -m "Added new feature" mycontainer mynewimage:tag
```

### Отладка контейнеров
```bash
# Подключение к контейнеру
docker attach mycontainer

# Отключение без остановки (Ctrl+P, Ctrl+Q)

# Просмотр портов
docker port mycontainer
docker port mycontainer 80

# Ожидание завершения
docker wait mycontainer

# Получение кода выхода
docker inspect --format='{{.State.ExitCode}}' mycontainer

# Обновление конфигурации
docker update --memory=1g mycontainer
docker update --restart=unless-stopped mycontainer
```

## 💾 Volumes и хранение данных

### Управление volumes
```bash
# Создание volume
docker volume create myvolume
docker volume create --driver local myvolume

# Создание с опциями драйвера
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/volume1/docker \
  myvolume

# Список volumes
docker volume ls
docker volume ls --filter "driver=local"
docker volume ls --filter "dangling=true"

# Информация о volume
docker inspect myvolume
docker volume inspect myvolume

# Удаление volumes
docker volume rm myvolume
docker volume rm volume1 volume2 volume3

# Удаление неиспользуемых volumes
docker volume prune
docker volume prune --filter "label!=keep"
```

### Использование volumes
```bash
# Именованные volumes
docker run -v myvolume:/app/data nginx
docker run --mount source=myvolume,target=/app/data nginx

# Bind mounts
docker run -v /host/path:/container/path nginx
docker run --mount type=bind,source=/host/path,target=/container/path nginx

# Read-only mounts
docker run -v myvolume:/app/data:ro nginx
docker run --mount source=myvolume,target=/app/data,readonly nginx

# tmpfs mounts (в памяти)
docker run --tmpfs /tmp nginx
docker run --mount type=tmpfs,target=/tmp,tmpfs-size=100m nginx

# Анонимные volumes
docker run -v /app/data nginx

# Копирование данных между volumes
docker run --rm -v source_vol:/source -v target_vol:/target \
  alpine cp -a /source/. /target/

# Резервное копирование volume
docker run --rm -v myvolume:/data -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Восстановление volume
docker run --rm -v myvolume:/data -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data
```

## 🌐 Сети

### Управление сетями
```bash
# Список сетей
docker network ls
docker network ls --filter "driver=bridge"
docker network ls --filter "scope=local"

# Создание сетей
docker network create mynetwork
docker network create --driver bridge mynetwork
docker network create --driver overlay --attachable mynetwork

# Создание с настройками
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  mynetwork

# Информация о сети
docker network inspect mynetwork
docker network inspect bridge

# Удаление сетей
docker network rm mynetwork
docker network prune  # удаление неиспользуемых сетей
```

### Подключение к сетям
```bash
# Запуск контейнера в сети
docker run --network mynetwork nginx
docker run --network=host nginx
docker run --network=none nginx

# Подключение работающего контейнера к сети
docker network connect mynetwork mycontainer
docker network connect --ip 172.20.0.10 mynetwork mycontainer

# Отключение от сети
docker network disconnect mynetwork mycontainer
docker network disconnect -f mynetwork mycontainer  # принудительно

# Создание алиасов в сети
docker network connect --alias web mynetwork mycontainer
docker run --network mynetwork --network-alias api nginx
```

### Тестирование сетевой связности
```bash
# Проверка связности между контейнерами
docker exec container1 ping container2
docker exec container1 nslookup container2
docker exec container1 curl http://container2:80

# Просмотр сетевых настроек контейнера
docker exec mycontainer ip addr show
docker exec mycontainer ip route
docker exec mycontainer cat /etc/resolv.conf

# Анализ сетевого трафика
docker exec mycontainer netstat -tlnp
docker exec mycontainer ss -tlnp
```

## 🐙 Docker Compose

### Основные команды
```bash
# Запуск сервисов
docker-compose up
docker-compose up -d  # в фоновом режиме
docker-compose up --build  # с пересборкой образов

# Запуск конкретных сервисов
docker-compose up web database
docker-compose up --scale web=3

# Остановка сервисов
docker-compose down
docker-compose down -v  # с удалением volumes
docker-compose down --remove-orphans

# Управление сервисами
docker-compose start
docker-compose stop
docker-compose restart
docker-compose pause
docker-compose unpause

# Управление конкретными сервисами
docker-compose start web
docker-compose stop database
docker-compose restart api
```

### Мониторинг и отладка
```bash
# Статус сервисов
docker-compose ps
docker-compose ps --services
docker-compose ps -q  # только ID

# Логи
docker-compose logs
docker-compose logs -f  # следить за логами
docker-compose logs web
docker-compose logs --tail=100 --since=1h web

# Выполнение команд
docker-compose exec web bash
docker-compose exec -T web ls -la
docker-compose run --rm web python manage.py migrate

# Статистика ресурсов
docker-compose top
docker-compose top web

# События
docker-compose events
docker-compose events web
```

### Конфигурация
```bash
# Валидация конфигурации
docker-compose config
docker-compose config --resolve-image-digests
docker-compose config --quiet

# Использование нескольких файлов
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Переменные окружения
docker-compose --env-file .env.prod up

# Профили
docker-compose --profile production up
docker-compose --profile dev --profile test up

# Проект
docker-compose -p myproject up
```

### Сборка и образы
```bash
# Сборка образов
docker-compose build
docker-compose build --no-cache
docker-compose build web

# Сборка с аргументами
docker-compose build --build-arg VERSION=1.0

# Получение образов
docker-compose pull
docker-compose pull web

# Публикация образов
docker-compose push
```

## 🐝 Docker Swarm

### Инициализация кластера
```bash
# Инициализация Swarm
docker swarm init
docker swarm init --advertise-addr 192.168.1.100

# Получение токенов для присоединения
docker swarm join-token worker
docker swarm join-token manager

# Присоединение к кластеру
docker swarm join --token TOKEN 192.168.1.100:2377

# Информация о кластере
docker info
docker node ls
docker node inspect self
```

### Управление узлами
```bash
# Список узлов
docker node ls
docker node ls --filter "role=manager"

# Информация об узле
docker node inspect nodename
docker node inspect --pretty nodename

# Обновление узла
docker node update --availability drain nodename
docker node update --role manager nodename

# Удаление узла
docker node rm nodename
docker node rm --force nodename

# Покидание кластера
docker swarm leave
docker swarm leave --force  # для manager
```

### Управление сервисами
```bash
# Создание сервиса
docker service create --name web nginx
docker service create --name web --replicas 3 nginx
docker service create --name web -p 80:80 nginx

# Список сервисов
docker service ls
docker service ls --filter "name=web"

# Информация о сервисе
docker service inspect web
docker service inspect --pretty web

# Обновление сервиса
docker service update --replicas 5 web
docker service update --image nginx:alpine web
docker service update --env-add NODE_ENV=production web

# Масштабирование
docker service scale web=10
docker service scale web=3 api=5

# Удаление сервиса
docker service rm web
```

### Управление задачами
```bash
# Список задач сервиса
docker service ps web
docker service ps --no-trunc web

# Логи сервиса
docker service logs web
docker service logs -f web

# Откат сервиса
docker service rollback web
```

### Secrets и Configs
```bash
# Создание секретов
echo "mysecret" | docker secret create db_password -
docker secret create ssl_cert ./cert.pem

# Список секретов
docker secret ls

# Информация о секрете
docker secret inspect db_password

# Использование секретов в сервисе
docker service create --name web --secret db_password nginx

# Удаление секрета
docker secret rm db_password

# Создание конфигураций
docker config create nginx_conf ./nginx.conf

# Список конфигураций
docker config ls

# Использование конфигураций
docker service create --name web --config nginx_conf nginx

# Удаление конфигурации
docker config rm nginx_conf
```

### Стеки
```bash
# Развертывание стека
docker stack deploy -c docker-compose.yml mystack

# Список стеков
docker stack ls

# Сервисы стека
docker stack services mystack

# Задачи стека
docker stack ps mystack

# Удаление стека
docker stack rm mystack
```

## 🔒 Безопасность

### Управление пользователями и правами
```bash
# Запуск от конкретного пользователя
docker run -u 1000:1000 nginx
docker run --user $(id -u):$(id -g) nginx

# Создание пользователя в Dockerfile
# RUN groupadd -r appuser && useradd -r -g appuser appuser
# USER appuser

# Проверка пользователя в контейнере
docker exec mycontainer whoami
docker exec mycontainer id
```

### Capabilities и привилегии
```bash
# Запуск в привилегированном режиме
docker run --privileged nginx

# Добавление capabilities
docker run --cap-add=NET_ADMIN nginx
docker run --cap-add=SYS_TIME nginx

# Удаление capabilities
docker run --cap-drop=ALL nginx
docker run --cap-drop=CHOWN nginx

# Безопасные опции
docker run --security-opt no-new-privileges nginx
docker run --read-only nginx
docker run --tmpfs /tmp nginx
```

### Сканирование на уязвимости
```bash
# Встроенное сканирование Docker (если включено)
docker scan nginx
docker scan myapp:latest

# Использование внешних инструментов
# Trivy
trivy image nginx
trivy image --severity HIGH,CRITICAL nginx

# Clair
# Anchore
```

### Подписывание образов
```bash
# Docker Content Trust
export DOCKER_CONTENT_TRUST=1
docker push myregistry/myapp:signed

# Проверка подписи
docker pull myregistry/myapp:signed
```

## 📊 Мониторинг и отладка

### Системная информация
```bash
# Использование ресурсов
docker system df
docker system df -v

# События системы
docker events
docker events --filter type=container
docker events --filter container=mycontainer

# Статистика контейнеров
docker stats
docker stats --no-stream
docker stats mycontainer
```

### Анализ производительности
```bash
# Топ процессов в контейнере
docker top mycontainer
docker top mycontainer aux

# Использование ресурсов
docker exec mycontainer top
docker exec mycontainer htop
docker exec mycontainer free -h
docker exec mycontainer df -h

# Сетевая активность
docker exec mycontainer netstat -i
docker exec mycontainer ss -tuln
```

### Отладка проблем
```bash
# Детальная информация
docker inspect mycontainer
docker inspect --format='{{.State.Status}}' mycontainer
docker inspect --format='{{.Config.Env}}' mycontainer

# Анализ слоев образа
docker history myimage
docker history --no-trunc myimage

# Изменения в файловой системе
docker diff mycontainer

# Проверка health check
docker inspect --format='{{.State.Health.Status}}' mycontainer
```

### Логирование
```bash
# Просмотр логов
docker logs mycontainer
docker logs -f mycontainer
docker logs --tail 100 mycontainer
docker logs --since="2023-01-01T00:00:00" mycontainer

# Настройка драйвера логирования
docker run --log-driver=json-file --log-opt max-size=10m nginx
docker run --log-driver=syslog nginx
docker run --log-driver=journald nginx

# Отключение логирования
docker run --log-driver=none nginx
```

## ⚡ Оптимизация

### Очистка системы
```bash
# Полная очистка неиспользуемых ресурсов
docker system prune
docker system prune -a  # включая неиспользуемые образы
docker system prune -f  # без подтверждения

# Очистка конкретных ресурсов
docker container prune  # остановленные контейнеры
docker image prune      # висячие образы
docker image prune -a   # неиспользуемые образы
docker volume prune     # неиспользуемые volumes
docker network prune    # неиспользуемые сети

# Очистка с фильтрами
docker image prune --filter "until=24h"
docker container prune --filter "until=1h"
docker volume prune --filter "label!=keep"
```

### Оптимизация образов
```bash
# Многоэтапная сборка
# FROM node:16 AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci
# COPY . .
# RUN npm run build
# 
# FROM nginx:alpine
# COPY --from=builder /app/dist /usr/share/nginx/html

# Использование .dockerignore
# node_modules
# .git
# *.log
# README.md

# Минимизация слоев
# RUN apt-get update && \
#     apt-get install -y package1 package2 && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*
```

### BuildKit и кэширование
```bash
# Включение BuildKit
export DOCKER_BUILDKIT=1

# Использование BuildKit возможностей
docker build --cache-from myapp:cache .
docker build --cache-to type=registry,ref=myapp:cache .

# Кэш монтирование
# RUN --mount=type=cache,target=/var/cache/apt \
#     apt-get update && apt-get install -y package

# Секреты в BuildKit
echo "secret" | docker build --secret id=mysecret,src=- .
```

### Мониторинг размеров
```bash
# Анализ размеров образов
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h

# Инструменты анализа
# dive - анализ слоев образа
dive myimage:latest

# docker-slim - оптимизация образов
docker-slim build myimage:latest
```

---

## 🎯 Полезные алиасы и функции

Добавьте в ваш `.bashrc` или `.zshrc`:

```bash
# Docker алиасы
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -f'

# Функции
# Подключиться к контейнеру
dsh() {
    docker exec -it $1 /bin/bash || docker exec -it $1 /bin/sh
}

# Остановить и удалить контейнер
drm() {
    docker stop $1 && docker rm $1
}

# Удалить образ со всеми тегами
drmi() {
    docker images | grep $1 | awk '{print $3}' | xargs docker rmi -f
}
```

---

Этот справочник покрывает большинство команд Docker, которые вы будете использовать в повседневной работе. Сохраните его как справочный материал и обращайтесь к нему при необходимости!
