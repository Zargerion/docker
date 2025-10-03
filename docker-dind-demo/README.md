# 🐳 Docker-in-Docker (DinD) Демонстрация

## 🎯 Что такое Docker-in-Docker?

**Docker-in-Docker (DinD)** - это запуск Docker daemon внутри Docker контейнера. Это позволяет создавать и управлять контейнерами изнутри другого контейнера.

## 🏗️ Архитектура

```
Host Docker
├─ docker-dind контейнер
│  ├─ Docker daemon (внутренний)
│  ├─ Контейнеры внутри DinD
│  └─ Docker API (порт 2376)
├─ docker-client контейнер
│  └─ Docker CLI для управления DinD
└─ portainer контейнер
   └─ Веб-интерфейс управления
```

## 🚀 Запуск демонстрации

```bash
# Запустить DinD
docker-compose up -d

# Проверить статус
docker-compose ps

# Посмотреть логи
docker-compose logs docker-dind
```

## 🔧 Использование

### 1. Подключиться к клиенту
```bash
docker exec -it docker-client sh
```

### 2. Проверить Docker внутри DinD
```bash
# Внутри docker-client контейнера
docker version
docker info
```

### 3. Создать контейнер внутри DinD
```bash
# Запустить nginx внутри DinD
docker run -d --name test-nginx -p 8080:80 nginx

# Проверить контейнеры
docker ps

# Остановить контейнер
docker stop test-nginx
```

### 4. Веб-интерфейс Portainer
- Открыть: http://localhost:9000
- Создать аккаунт администратора
- Подключиться к Docker environment

## 🎯 Зачем нужно DinD?

### 1. CI/CD пайплайны
```yaml
# GitLab CI
build:
  image: docker:dind
  services:
    - docker:dind
  script:
    - docker build -t myapp .
    - docker run myapp
```

### 2. Тестирование Docker
- Тестирование Docker образов
- Проверка Dockerfile
- Изоляция тестов

### 3. Разработка
- Локальная разработка с Docker
- Тестирование контейнеров
- Отладка Docker конфигураций

### 4. Обучение
- Изучение Docker без влияния на хост
- Безопасные эксперименты
- Демонстрации

## ⚠️ Важные моменты

### Безопасность
- `privileged: true` - дает полные права
- Изоляция от хоста
- Ограниченный доступ к ресурсам

### Производительность
- Двойная виртуализация
- Больше потребление ресурсов
- Медленнее чем обычные контейнеры

### Альтернативы
- Docker Socket Mounting (DooD)
- Kubernetes DinD
- Podman-in-Podman

## 🛠️ Команды для демонстрации

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Очистка
docker-compose down -v --rmi all

# Логи
docker-compose logs -f docker-dind
```

## 📊 Мониторинг

```bash
# Статистика ресурсов
docker stats docker-dind docker-client portainer

# Использование диска
docker system df

# Процессы в DinD
docker exec docker-dind ps aux
```
