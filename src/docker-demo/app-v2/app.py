from flask import Flask
import os
import json

app = Flask(__name__)

@app.route('/')
def hello():
    return {
        "message": "欢迎访问云计算大作业Docker演示应用",
        "version": "v2.0（优化版）",
        "status": "运行正常"
    }

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

@app.route('/info')
def info():
    return {
        "python_version": os.sys.version,
        "system": os.name,
        "environment": dict(os.environ)
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)