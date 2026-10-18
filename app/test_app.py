import time

import pytest

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_root(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Welcome to the Liatrio Demo API!"
    assert {"/", "/api", "/health", "/version"} <= set(data["endpoints"])


def test_api_message_and_timestamp(client):
    response = client.get("/api")
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Automate all the things!"
    assert isinstance(data["timestamp"], int)
    assert abs(int(time.time()) - data["timestamp"]) < 10


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert data["service"] == "liatrio-demo-api"
    assert "started_at" in data


def test_version_defaults(client, monkeypatch):
    monkeypatch.delenv("APP_VERSION", raising=False)
    monkeypatch.delenv("ENVIRONMENT", raising=False)
    data = client.get("/version").get_json()
    assert data["version"] == "dev"
    assert data["environment"] == "development"


def test_version_from_environment(client, monkeypatch):
    monkeypatch.setenv("APP_VERSION", "abc1234")
    monkeypatch.setenv("ENVIRONMENT", "dev")
    data = client.get("/version").get_json()
    assert data["version"] == "abc1234"
    assert data["environment"] == "dev"


def test_unknown_route_returns_json_404(client):
    response = client.get("/does-not-exist")
    assert response.status_code == 404
    assert response.get_json()["error"] == "Not Found"


@pytest.mark.parametrize("path", ["/", "/api", "/health", "/version"])
def test_responses_are_json(client, path):
    assert client.get(path).content_type == "application/json"
