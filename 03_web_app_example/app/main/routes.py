"""
Основные маршруты приложения
"""
from flask import render_template, jsonify, request
from app.main import bp
from app import db, cache
from app.models import User, Post
import os
import psutil

@bp.route('/')
@bp.route('/index')
def index():
    """Главная страница"""
    posts = Post.query.order_by(Post.timestamp.desc()).limit(10).all()
    return render_template('index.html', title='Главная', posts=posts)

@bp.route('/health')
def health():
    """Health check endpoint для Docker"""
    try:
        # Проверка подключения к БД
        db.session.execute('SELECT 1')
        db_status = 'healthy'
    except Exception as e:
        db_status = f'unhealthy: {str(e)}'
    
    # Информация о системе
    memory_info = psutil.virtual_memory()
    
    return jsonify({
        'status': 'healthy' if db_status == 'healthy' else 'unhealthy',
        'database': db_status,
        'memory_usage': f"{memory_info.percent}%",
        'environment': os.getenv('FLASK_ENV', 'production'),
        'version': '1.0.0'
    })

@bp.route('/stats')
@cache.cached(timeout=60)  # Кэшируем на 1 минуту
def stats():
    """Статистика приложения"""
    user_count = User.query.count()
    post_count = Post.query.count()
    
    return jsonify({
        'users': user_count,
        'posts': post_count,
        'cached_at': cache.get('stats_cached_at') or 'now'
    })

@bp.route('/docker-info')
def docker_info():
    """Информация о Docker контейнере"""
    container_info = {
        'hostname': os.getenv('HOSTNAME', 'unknown'),
        'environment': dict(os.environ),
        'working_directory': os.getcwd(),
        'python_version': os.sys.version,
    }
    
    # Попытка получить информацию о контейнере
    try:
        with open('/proc/1/cgroup', 'r') as f:
            cgroup_info = f.read()
            container_info['is_docker'] = 'docker' in cgroup_info
    except:
        container_info['is_docker'] = False
    
    return jsonify(container_info)
