#!/usr/bin/env python3
"""
LiteLLM Workbench 管理看板后端服务器
支持读取和写入配置文件
"""

import http.server
import json
import os
import socketserver
from pathlib import Path
from urllib.parse import urlparse, parse_qs

# 配置
PORT = 8080
CONFIG_FILE = Path(__file__).parent / "litellm_config.yaml"

class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    """自定义请求处理器"""

    def do_GET(self):
        """处理GET请求"""
        parsed_path = urlparse(self.path)

        # API: 获取配置文件
        if parsed_path.path == '/api/config':
            self.send_response(200)
            self.send_header('Content-Type', 'text/yaml; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            if CONFIG_FILE.exists():
                with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                    config_content = f.read()
                self.wfile.write(config_content.encode('utf-8'))
            else:
                self.wfile.write(b'# Config file not found')
            return

        # API: 获取服务状态
        if parsed_path.path == '/api/status':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            status = {
                'headroom': self._check_service('http://127.0.0.1:8787/health'),
                'litellm': self._check_service('http://127.0.0.1:4000/health/liveliness'),
                'ollama': self._check_service('http://127.0.0.1:11434/api/tags'),
            }
            self.wfile.write(json.dumps(status, ensure_ascii=False).encode('utf-8'))
            return

        # 默认: 提供静态文件
        super().do_GET()

    def do_POST(self):
        """处理POST请求"""
        parsed_path = urlparse(self.path)

        # API: 保存配置文件
        if parsed_path.path == '/api/config':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)

            try:
                config_content = post_data.decode('utf-8')

                # 备份原配置
                if CONFIG_FILE.exists():
                    backup_file = CONFIG_FILE.with_suffix('.yaml.bak')
                    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                        backup_content = f.read()
                    with open(backup_file, 'w', encoding='utf-8') as f:
                        f.write(backup_content)

                # 保存新配置
                with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
                    f.write(config_content)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()

                response = {
                    'success': True,
                    'message': '配置已保存',
                    'file': str(CONFIG_FILE)
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))

            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()

                response = {
                    'success': False,
                    'message': f'保存失败: {str(e)}'
                }
                self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
            return

        self.send_response(404)
        self.end_headers()

    def do_OPTIONS(self):
        """处理OPTIONS请求（CORS预检）"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def _check_service(self, url):
        """检查服务状态"""
        try:
            import urllib.request
            response = urllib.request.urlopen(url, timeout=2)
            return {'status': 'running', 'code': response.status}
        except Exception as e:
            return {'status': 'stopped', 'error': str(e)}

def main():
    """主函数"""
    with socketserver.TCPServer(("", PORT), DashboardHandler) as httpd:
        print(f"🚀 LiteLLM Workbench 管理看板服务器")
        print(f"================================")
        print(f"")
        print(f"📊 管理看板地址: http://localhost:{PORT}/dashboard.html")
        print(f"")
        print(f"按 Ctrl+C 停止服务器")
        print(f"")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
