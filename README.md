# 🐳 Полное руководство по изучению Docker

Добро пожаловать в комплексный курс по изучению Docker! Этот репозиторий содержит все необходимые материалы для глубокого понимания контейнеризации с Docker - от основ до продвинутых техник.

## 📚 Содержание курса

### 🎯 Основы Docker
1. **[01_basic_dockerfile](./01_basic_dockerfile/)** - Базовый Dockerfile с подробными объяснениями всех команд
2. **[02_multistage_build](./02_multistage_build/)** - Многоэтапная сборка для оптимизации образов
3. **[03_web_app_example](./03_web_app_example/)** - Полноценное веб-приложение с Flask и PostgreSQL

### 🗄️ Работа с данными и сетями
4. **[04_database_volumes](./04_database_volumes/)** - Работа с базами данных и volumes
5. **[05_microservices_compose](./05_microservices_compose/)** - Микросервисная архитектура с Docker Compose
6. **[06_networking_example](./06_networking_example/)** - Подробное изучение Docker сетей

### 🚀 Продвинутые возможности
7. **[07_advanced_features](./07_advanced_features/)** - BuildKit, secrets, multi-platform builds
8. **[11_docker_registry](./11_docker_registry/)** - Docker Registry: приватные репозитории и Docker Hub
9. **[08_commands_reference](./08_commands_reference/)** - Полный справочник Docker команд
10. **[09_best_practices](./09_best_practices/)** - Лучшие практики и оптимизация
11. **[10_troubleshooting](./10_troubleshooting/)** - Руководство по устранению проблем

## 🎓 Как использовать этот курс

### Для начинающих
1. Начните с **01_basic_dockerfile** для понимания основ
2. Изучите **02_multistage_build** для оптимизации образов
3. Попрактикуйтесь с **03_web_app_example** для реального опыта
4. Изучите **08_commands_reference** как справочник

### Для продвинутых пользователей
1. **05_microservices_compose** - сложная архитектура
2. **06_networking_example** - глубокое понимание сетей
3. **07_advanced_features** - современные возможности Docker
4. **11_docker_registry** - приватные репозитории и Docker Hub
5. **09_best_practices** - промышленные стандарты

### Для решения проблем
- **10_troubleshooting** - когда что-то не работает
- **08_commands_reference** - быстрый поиск команд

## 🛠️ Требования

### Системные требования
- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM (рекомендуется 8GB)
- 10GB свободного места на диске

### Установка Docker

#### Windows
```powershell
# Скачайте Docker Desktop с официального сайта
# https://www.docker.com/products/docker-desktop/

# Или через Chocolatey
choco install docker-desktop
```

#### macOS
```bash
# Скачайте Docker Desktop или используйте Homebrew
brew install --cask docker
```

#### Linux (Ubuntu/Debian)
```bash
# Обновление пакетов
sudo apt-get update

# Установка зависимостей
sudo apt-get install ca-certificates curl gnupg lsb-release

# Добавление GPG ключа Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Добавление репозитория
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
```

### Проверка установки
```bash
docker --version
docker-compose --version
docker run hello-world
```

## 🚀 Быстрый старт

### 1. Клонирование репозитория
```bash
git clone <repository-url>
cd docker-learning
```

### 2. Первый пример
```bash
cd 01_basic_dockerfile
docker build -t basic-example .
docker run -d -p 8080:8080 --name basic-container basic-example
```

### 3. Проверка работы
```bash
curl http://localhost:8080
docker logs basic-container
```

### 4. Веб-приложение
```bash
cd ../03_web_app_example
docker-compose up -d
```

Откройте http://localhost:5000 в браузере.

## 📖 Структура каждого примера

Каждая папка содержит:
- **Dockerfile** - с подробными комментариями на русском языке
- **docker-compose.yml** - для сложных примеров
- **Исходный код** - примеры приложений
- **Скрипты** - вспомогательные утилиты
- **README или комментарии** - объяснения и команды для запуска

## 🎯 Цели обучения

После изучения всех материалов вы будете знать:

### Основы
- ✅ Что такое контейнеризация и зачем она нужна
- ✅ Все основные команды Docker
- ✅ Как писать эффективные Dockerfile
- ✅ Работа с образами и контейнерами

### Продвинутые темы
- ✅ Многоэтапная сборка образов
- ✅ Docker Compose для многоконтейнерных приложений
- ✅ Сетевое взаимодействие между контейнерами
- ✅ Управление данными с volumes

### Профессиональные навыки
- ✅ Микросервисная архитектура с Docker
- ✅ Безопасность контейнеров
- ✅ Оптимизация производительности
- ✅ Мониторинг и логирование
- ✅ CI/CD интеграция

### Практические умения
- ✅ Отладка проблем с контейнерами
- ✅ Развертывание в продакшене
- ✅ Масштабирование приложений
- ✅ Лучшие практики индустрии

## 🔧 Полезные команды

### Основные команды Docker
```bash
# Информация о системе
docker info
docker version

# Работа с образами
docker images
docker build -t name:tag .
docker pull nginx
docker push myregistry/image:tag

# Работа с контейнерами
docker ps
docker run -d --name container nginx
docker exec -it container bash
docker logs -f container
docker stop container
docker rm container

# Очистка системы
docker system prune -a
```

### Docker Compose команды
```bash
# Запуск сервисов
docker-compose up -d
docker-compose up --build

# Управление
docker-compose ps
docker-compose logs -f service
docker-compose exec service bash
docker-compose down -v
```

## 📊 Прогресс изучения

Отмечайте изученные темы:

- [ ] **01_basic_dockerfile** - Основы Dockerfile
- [ ] **02_multistage_build** - Многоэтапная сборка
- [ ] **03_web_app_example** - Веб-приложение
- [ ] **04_database_volumes** - Базы данных и volumes
- [ ] **05_microservices_compose** - Микросервисы
- [ ] **06_networking_example** - Сети Docker
- [ ] **07_advanced_features** - Продвинутые возможности
- [ ] **11_docker_registry** - Docker Registry и Docker Hub
- [ ] **08_commands_reference** - Справочник команд
- [ ] **09_best_practices** - Лучшие практики
- [ ] **10_troubleshooting** - Устранение проблем

## 🤝 Практические упражнения

### Уровень 1: Новичок
1. Создайте свой первый Dockerfile для простого приложения
2. Соберите и запустите контейнер
3. Пробросьте порты и проверьте работу
4. Изучите логи контейнера

### Уровень 2: Средний
1. Создайте многоэтапную сборку для Node.js приложения
2. Настройте Docker Compose для приложения с базой данных
3. Создайте пользовательскую сеть Docker
4. Настройте volumes для персистентного хранения

### Уровень 3: Продвинутый
1. Создайте микросервисную архитектуру с API Gateway
2. Настройте мониторинг с Prometheus и Grafana
3. Реализуйте CI/CD пайплайн с Docker
4. Оптимизируйте образы для продакшена

## 🆘 Получение помощи

### Если что-то не работает:
1. Проверьте **10_troubleshooting** - там решения частых проблем
2. Изучите **08_commands_reference** - возможно, неправильная команда
3. Проверьте логи: `docker logs container_name`
4. Проверьте статус: `docker ps -a`

### Полезные ресурсы:
- [Официальная документация Docker](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/) - репозиторий образов
- [Docker Compose документация](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📝 Заметки

### Важные моменты для запоминания:
- Всегда используйте конкретные версии образов (не `latest`)
- Запускайте контейнеры от непривилегированного пользователя
- Используйте `.dockerignore` для исключения ненужных файлов
- Объединяйте RUN команды для уменьшения слоев
- Используйте многоэтапную сборку для оптимизации размера

### Команды для быстрого доступа:
```bash
# Алиасы для удобства (добавьте в .bashrc или .zshrc)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dlog='docker logs -f'
alias dexec='docker exec -it'
```

---

## 🎉 Заключение

Этот курс предоставляет полное погружение в мир Docker - от базовых концепций до продвинутых техник промышленного уровня. Каждый пример содержит подробные комментарии на русском языке и готов к запуску.

**Удачи в изучении Docker! 🐳**

---

*Создано с ❤️ для изучения Docker на русском языке*
