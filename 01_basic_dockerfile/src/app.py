#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Простое Flask приложение для демонстрации Docker
"""

from flask import Flask, jsonify
import os
import sys

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Привет от Docker контейнера!',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'python_version': sys.version
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/env')
def env_vars():
    return jsonify({
        'APP_HOME': os.getenv('APP_HOME'),
        'NODE_VERSION': os.getenv('NODE_VERSION'),
        'PATH': os.getenv('PATH')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
