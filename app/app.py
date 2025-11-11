"""
Liatrio Demo REST API Application
A simple Flask application that demonstrates cloud-native deployment practices.
"""

from flask import Flask, jsonify
import time
import os
from datetime import datetime

app = Flask(__name__)

# Configuration
PORT = int(os.environ.get('PORT', 8080))
HOST = os.environ.get('HOST', '0.0.0.0')

@app.route('/', methods=['GET'])
def root():
    """Root endpoint returning welcome message"""
    return jsonify({
        "message": "Welcome to the Liatrio Demo API!",
        "endpoints": {
            "/": "Welcome endpoint",
            "/api": "Main API endpoint", 
            "/health": "Health check endpoint",
            "/metrics": "Service metrics"
        },
        "timestamp": int(time.time())
    })

@app.route('/api', methods=['GET'])
def api():
    """Main API endpoint as specified in the problem statement"""
    return jsonify({
        "message": "Automate all the things!",
        "timestamp": int(time.time())
    })

@app.route('/test', methods=['GET'])
def test():
    """Main API endpoint as specified in the problem statement"""
    return jsonify({
        "message": "tested",
        "timestamp": int(time.time())
    })


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint for Kubernetes probes"""
    return jsonify({
        "status": "healthy",
        "service": "liatrio-demo-api",
        "timestamp": int(time.time()),
        "uptime": datetime.now().isoformat()
    }), 200

@app.route('/metrics', methods=['GET'])
def metrics():
    """Basic metrics endpoint for monitoring"""
    return jsonify({
        "service": "liatrio-demo-api",
        "version": "1.0.0",
        "environment": os.environ.get('ENVIRONMENT', 'development'),
        "timestamp": int(time.time()),
        "host": HOST,
        "port": PORT
    })

@app.route('/version', methods=['GET'])
def version():
    """Version endpoint for semantic release testing"""
    return jsonify({
        "service": "liatrio-demo-api",
        "version": "1.0.0",
        "semantic_release": "enabled",
        "build_info": {
            "timestamp": int(time.time()),
            "environment": os.environ.get('ENVIRONMENT', 'development')
        },
        "message": "Semantic release testing endpoint"
    })

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "error": "Not Found",
        "message": "The requested endpoint does not exist",
        "timestamp": int(time.time())
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({
        "error": "Internal Server Error",
        "message": "An unexpected error occurred",
        "timestamp": int(time.time())
    }), 500

if __name__ == '__main__':
    print(f"Starting Liatrio Demo API on {HOST}:{PORT}")
    print(f"Environment: {os.environ.get('ENVIRONMENT', 'development')}")
    app.run(
        host=HOST,
        port=PORT,
        debug=os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    )