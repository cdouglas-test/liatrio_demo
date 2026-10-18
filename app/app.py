import os
import time
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

SERVICE_NAME = "liatrio-demo-api"
STARTED_AT = datetime.now(timezone.utc).isoformat()


def now():
    return int(time.time())


@app.route("/")
def root():
    return jsonify({
        "message": "Welcome to the Liatrio Demo API!",
        "endpoints": {
            "/": "Welcome endpoint",
            "/api": "Main API endpoint",
            "/health": "Health check endpoint",
            "/version": "Build information",
        },
        "timestamp": now(),
    })


@app.route("/api")
def api():
    return jsonify({
        "message": "Automate all the things!",
        "timestamp": now(),
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": SERVICE_NAME,
        "started_at": STARTED_AT,
        "timestamp": now(),
    })


@app.route("/version")
def version():
    return jsonify({
        "service": SERVICE_NAME,
        "version": os.environ.get("APP_VERSION", "dev"),
        "environment": os.environ.get("ENVIRONMENT", "development"),
        "timestamp": now(),
    })


@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "error": "Not Found",
        "message": "The requested endpoint does not exist",
        "timestamp": now(),
    }), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "error": "Internal Server Error",
        "message": "An unexpected error occurred",
        "timestamp": now(),
    }), 500


if __name__ == "__main__":
    app.run(
        host=os.environ.get("HOST", "0.0.0.0"),
        port=int(os.environ.get("PORT", 8080)),
        debug=os.environ.get("FLASK_DEBUG", "false").lower() == "true",
    )
