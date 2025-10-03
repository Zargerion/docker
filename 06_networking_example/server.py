#!/usr/bin/env python3
"""
Простой HTTP API сервер для демонстрации Docker сетей
"""

from flask import Flask, jsonify, request
import socket
import os
import subprocess
import json
from datetime import datetime

app = Flask(__name__)

def get_network_info():
    """Получает информацию о сети контейнера"""
    try:
        # Получаем информацию об интерфейсах
        result = subprocess.run(['ip', 'addr', 'show'], 
                               capture_output=True, text=True)
        interfaces = result.stdout
        
        # Получаем таблицу маршрутизации
        result = subprocess.run(['ip', 'route'], 
                               capture_output=True, text=True)
        routes = result.stdout
        
        # Получаем DNS настройки
        try:
            with open('/etc/resolv.conf', 'r') as f:
                dns_config = f.read()
        except:
            dns_config = "Недоступно"
        
        return {
            'interfaces': interfaces,
            'routes': routes,
            'dns': dns_config
        }
    except Exception as e:
        return {'error': str(e)}

@app.route('/')
def home():
    """Главная страница API"""
    return jsonify({
        'service': 'Docker Network Demo API',
        'container': socket.gethostname(),
        'api_name': os.getenv('API_NAME', 'unknown'),
        'port': os.getenv('API_PORT', '8080'),
        'timestamp': datetime.now().isoformat(),
        'endpoints': [
            '/health',
            '/network-info',
            '/connectivity/<host>',
            '/dns/<hostname>',
            '/ping/<host>'
        ]
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'container': socket.gethostname(),
        'service': os.getenv('API_NAME', 'api-server'),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/network-info')
def network_info():
    """Возвращает информацию о сети"""
    info = get_network_info()
    info.update({
        'hostname': socket.gethostname(),
        'container_ip': socket.gethostbyname(socket.gethostname()),
        'environment': {
            'DATABASE_HOST': os.getenv('DATABASE_HOST'),
            'API_NAME': os.getenv('API_NAME'),
            'API_PORT': os.getenv('API_PORT')
        }
    })
    return jsonify(info)

@app.route('/connectivity/<host>')
def test_connectivity(host):
    """Тестирует подключение к указанному хосту"""
    port = request.args.get('port', '80')
    
    results = {
        'target': f"{host}:{port}",
        'timestamp': datetime.now().isoformat(),
        'tests': {}
    }
    
    # DNS тест
    try:
        result = subprocess.run(['nslookup', host], 
                               capture_output=True, text=True, timeout=5)
        results['tests']['dns'] = {
            'success': result.returncode == 0,
            'output': result.stdout if result.returncode == 0 else result.stderr
        }
    except Exception as e:
        results['tests']['dns'] = {'success': False, 'error': str(e)}
    
    # Ping тест
    try:
        result = subprocess.run(['ping', '-c', '3', '-W', '3', host], 
                               capture_output=True, text=True, timeout=10)
        results['tests']['ping'] = {
            'success': result.returncode == 0,
            'output': result.stdout.split('\n')[-3:-1] if result.returncode == 0 else result.stderr
        }
    except Exception as e:
        results['tests']['ping'] = {'success': False, 'error': str(e)}
    
    # TCP подключение
    try:
        result = subprocess.run(['nc', '-z', '-w', '3', host, port], 
                               capture_output=True, text=True, timeout=5)
        results['tests']['tcp'] = {
            'success': result.returncode == 0,
            'port': port
        }
    except Exception as e:
        results['tests']['tcp'] = {'success': False, 'error': str(e)}
    
    return jsonify(results)

@app.route('/dns/<hostname>')
def dns_lookup(hostname):
    """Выполняет DNS lookup"""
    try:
        result = subprocess.run(['nslookup', hostname], 
                               capture_output=True, text=True, timeout=5)
        
        return jsonify({
            'hostname': hostname,
            'success': result.returncode == 0,
            'output': result.stdout if result.returncode == 0 else result.stderr,
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'hostname': hostname,
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/ping/<host>')
def ping_host(host):
    """Выполняет ping к хосту"""
    count = request.args.get('count', '3')
    
    try:
        result = subprocess.run(['ping', '-c', count, '-W', '3', host], 
                               capture_output=True, text=True, timeout=15)
        
        return jsonify({
            'host': host,
            'success': result.returncode == 0,
            'output': result.stdout.split('\n') if result.returncode == 0 else [result.stderr],
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'host': host,
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/ports')
def list_ports():
    """Показывает открытые порты"""
    try:
        result = subprocess.run(['netstat', '-tlnp'], 
                               capture_output=True, text=True)
        
        return jsonify({
            'ports': result.stdout.split('\n') if result.returncode == 0 else [],
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    port = int(os.getenv('API_PORT', 8080))
    print(f"🚀 Запуск API сервера на порту {port}")
    print(f"📡 Контейнер: {socket.gethostname()}")
    print(f"🔧 API Name: {os.getenv('API_NAME', 'api-server')}")
    
    app.run(host='0.0.0.0', port=port, debug=True)
