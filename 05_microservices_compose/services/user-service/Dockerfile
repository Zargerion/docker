# ===============================================
# DOCKERFILE ДЛЯ МИКРОСЕРВИСА ПОЛЬЗОВАТЕЛЕЙ
# ===============================================

FROM node:18-alpine AS builder

WORKDIR /app

# Копируем package files
COPY package*.json ./

# Устанавливаем зависимости
RUN npm ci --only=production && npm cache clean --force

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# Финальный образ
FROM node:18-alpine

# Создаем пользователя
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Устанавливаем зависимости для продакшена
RUN apk add --no-cache curl

# Копируем собранное приложение
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

# Создаем директории
RUN mkdir -p logs && chown nodejs:nodejs logs

# Переключаемся на непривилегированного пользователя
USER nodejs

# Открываем порт
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

# Запускаем приложение
CMD ["node", "dist/index.js"]

# ===============================================
# КОМАНДЫ ДЛЯ СБОРКИ:
# ===============================================
# docker build -t user-service .
# docker run -d -p 3001:3001 --name user-service user-service
