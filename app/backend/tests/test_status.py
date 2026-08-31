from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


def test_status_endpoint():
    response = client.get("/api/status")

    assert response.status_code == 200
    assert response.json() == {
        "application": "SecureCart API",
        "version": "0.1.0",
        "environment": "Development",
        "pod": "local-development",
        "status": "running",
    }
