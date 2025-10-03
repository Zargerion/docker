"""
Инициализация Flask приложения
"""
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_caching import Cache
import os

# Инициализация расширений
db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()
cache = Cache()

def create_app(config_name=None):
    """Фабрика приложений Flask"""
    app = Flask(__name__)
    
    # Загрузка конфигурации
    if config_name is None:
        config_name = os.getenv('FLASK_ENV', 'production')
    
    if config_name == 'development':
        app.config.from_object('config.DevelopmentConfig')
    elif config_name == 'testing':
        app.config.from_object('config.TestingConfig')
    else:
        app.config.from_object('config.ProductionConfig')
    
    # Инициализация расширений с приложением
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    cache.init_app(app)
    
    # Настройка login manager
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Пожалуйста, войдите для доступа к этой странице.'
    
    # Регистрация blueprints
    from app.main import bp as main_bp
    app.register_blueprint(main_bp)
    
    from app.auth import bp as auth_bp
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    from app.api import bp as api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Обработчики ошибок
    @app.errorhandler(404)
    def not_found_error(error):
        return {'error': 'Страница не найдена'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return {'error': 'Внутренняя ошибка сервера'}, 500
    
    return app

# Импорт моделей для миграций
from app import models
