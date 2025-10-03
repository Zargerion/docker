#!/usr/bin/env python3
"""
Точка входа для Flask приложения
"""
from app import create_app, db
from app.models import User, Post
import os

# Создаем приложение
app = create_app()

@app.shell_context_processor
def make_shell_context():
    """Контекст для flask shell"""
    return {
        'db': db, 
        'User': User, 
        'Post': Post
    }

@app.cli.command()
def create_admin():
    """Создание администратора"""
    from app.models import User
    
    admin = User(
        username='admin',
        email='admin@example.com'
    )
    admin.set_password('admin123')
    admin.is_admin = True
    
    db.session.add(admin)
    db.session.commit()
    print('Администратор создан: admin/admin123')

@app.cli.command()
def init_db():
    """Инициализация базы данных"""
    db.create_all()
    print('База данных инициализирована')

if __name__ == '__main__':
    # Запуск только для разработки
    # В продакшене используйте gunicorn
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
