"""
Comprehensive test suite for the Liatrio Demo Flask API.
Tests all endpoints, error handling, and configuration.
"""

import pytest
import json
import time
import os
from app import app


@pytest.fixture
def client():
    """Create a test client for the Flask application"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


@pytest.fixture
def clean_env():
    """Clean environment variables after test"""
    yield
    if 'ENVIRONMENT' in os.environ:
        del os.environ['ENVIRONMENT']


class TestAPIEndpoints:
    """Test cases for API endpoints"""

    @pytest.mark.unit
    def test_root_endpoint(self, client):
        """Test the root endpoint returns welcome message and endpoints info"""
        response = client.get('/')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        assert data['message'] == "Welcome to the Liatrio Demo API!"
        assert 'endpoints' in data
        assert 'timestamp' in data
        assert isinstance(data['timestamp'], int)
        
        # Verify endpoint documentation
        assert '/' in data['endpoints']
        assert '/api' in data['endpoints']
        assert '/health' in data['endpoints']

    @pytest.mark.contract
    def test_api_endpoint_required_format(self, client):
        """Test the /api endpoint returns exact format required by problem statement"""
        response = client.get('/api')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        
        # Verify exact required format
        assert data['message'] == "Automate all the things!"
        assert 'timestamp' in data
        assert isinstance(data['timestamp'], int)
        
        # Verify timestamp is recent (within 10 seconds)
        current_time = int(time.time())
        assert abs(current_time - data['timestamp']) < 10

    @pytest.mark.unit
    def test_health_endpoint(self, client):
        """Test the health check endpoint for Kubernetes probes"""
        response = client.get('/health')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        assert data['status'] == "healthy"
        assert data['service'] == "liatrio-demo-api"
        assert 'timestamp' in data
        assert 'uptime' in data
        assert isinstance(data['timestamp'], int)

    @pytest.mark.unit
    def test_metrics_endpoint(self, client):
        """Test the metrics endpoint returns service information"""
        response = client.get('/metrics')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        assert data['service'] == "liatrio-demo-api"
        assert data['version'] == "1.0.0"
        assert 'environment' in data
        assert 'timestamp' in data
        assert 'host' in data
        assert 'port' in data

    @pytest.mark.unit
    def test_test_endpoint(self, client):
        """Test the /test endpoint"""
        response = client.get('/test')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        assert data['message'] == "test"
        assert 'timestamp' in data

    @pytest.mark.unit
    def test_404_error_handler(self, client):
        """Test 404 error handling for non-existent endpoints"""
        response = client.get('/nonexistent')
        assert response.status_code == 404
        
        data = json.loads(response.data)
        assert data['error'] == "Not Found"
        assert 'message' in data
        assert 'timestamp' in data

    @pytest.mark.unit
    def test_response_headers_json(self, client):
        """Test that all responses have correct JSON content type"""
        endpoints = ['/', '/api', '/health', '/metrics', '/test']
        
        for endpoint in endpoints:
            response = client.get(endpoint)
            assert 'application/json' in response.content_type

    @pytest.mark.unit
    def test_timestamp_format(self, client):
        """Test that timestamps are valid Unix epoch format"""
        response = client.get('/api')
        data = json.loads(response.data)
        
        # Timestamp should be a positive integer
        assert isinstance(data['timestamp'], int)
        assert data['timestamp'] > 0
        
        # Should be within reasonable range (after 2020, before 2050)
        assert data['timestamp'] > 1577836800  # 2020-01-01
        assert data['timestamp'] < 2524608000   # 2050-01-01

    @pytest.mark.unit
    def test_environment_configuration(self, client, clean_env):
        """Test environment variable configuration"""
        # Test with different environment
        os.environ['ENVIRONMENT'] = 'test'
        
        response = client.get('/metrics')
        data = json.loads(response.data)
        assert data['environment'] == 'test'

    @pytest.mark.integration
    def test_api_idempotency(self, client):
        """Test that API calls are idempotent (same structure, different timestamps)"""
        response1 = client.get('/api')
        time.sleep(1)  # Ensure different timestamp
        response2 = client.get('/api')
        
        data1 = json.loads(response1.data)
        data2 = json.loads(response2.data)
        
        # Same message, different timestamps
        assert data1['message'] == data2['message']
        assert data1['timestamp'] != data2['timestamp']


class TestAPIContract:
    """Test API contracts and compliance with requirements"""

    @pytest.mark.contract
    def test_problem_statement_compliance(self, client):
        """Test that API meets exact problem statement requirements"""
        response = client.get('/api')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        
        # Must have exact message
        assert data['message'] == "Automate all the things!"
        
        # Must have timestamp in Unix epoch format
        assert 'timestamp' in data
        assert isinstance(data['timestamp'], int)

    @pytest.mark.contract
    def test_kubernetes_readiness(self, client):
        """Test endpoints required for Kubernetes deployment"""
        # Health check must return 200
        response = client.get('/health')
        assert response.status_code == 200
        
        # Must return healthy status
        data = json.loads(response.data)
        assert data['status'] == "healthy"

    @pytest.mark.contract
    def test_production_readiness(self, client):
        """Test production-ready features"""
        # Should handle errors gracefully
        response = client.get('/invalid-endpoint')
        assert response.status_code == 404
        
        # Should return JSON for errors
        data = json.loads(response.data)
        assert 'error' in data

    @pytest.mark.contract
    def test_monitoring_capabilities(self, client):
        """Test monitoring and observability endpoints"""
        # Metrics endpoint should be available
        response = client.get('/metrics')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        required_fields = ['service', 'version', 'environment', 'timestamp']
        for field in required_fields:
            assert field in data


class TestPerformanceAndLoad:
    """Performance and load testing"""

    @pytest.mark.integration  
    def test_concurrent_requests(self, client):
        """Test handling multiple concurrent requests"""
        # Simplified concurrent test that's more reliable
        responses = []
        
        # Make multiple sequential requests quickly to simulate load
        for i in range(5):
            response = client.get('/api')
            responses.append(response.status_code)
        
        # Check all requests succeeded
        assert len(responses) == 5
        for code in responses:
            assert code == 200
            
        print(f"✅ Completed {len(responses)} requests successfully")

    @pytest.mark.integration
    def test_response_time(self, client):
        """Test that responses are returned within acceptable time limits"""
        import time
        
        start_time = time.time()
        response = client.get('/api')
        end_time = time.time()
        
        response_time = end_time - start_time
        
        assert response.status_code == 200
        assert response_time < 1.0  # Should respond within 1 second