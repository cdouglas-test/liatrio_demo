#!/usr/bin/env python3
"""
Test script for the Liatrio Demo API
"""

import requests
import json
import time
import sys

def test_endpoint(url, expected_status=200, expected_keys=None):
    """Test an API endpoint"""
    try:
        response = requests.get(url, timeout=10)
        print(f"Testing {url}")
        print(f"Status Code: {response.status_code}")
        
        if response.status_code != expected_status:
            print(f"❌ Expected status {expected_status}, got {response.status_code}")
            return False
        
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
        
        if expected_keys:
            for key in expected_keys:
                if key not in data:
                    print(f"❌ Missing expected key: {key}")
                    return False
        
        print("✅ Test passed")
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

def main():
    """Run all tests"""
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080"
    
    print(f"Testing Liatrio Demo API at {base_url}")
    print("=" * 50)
    
    tests = [
        {
            "url": f"{base_url}/",
            "expected_keys": ["message", "endpoints", "timestamp"]
        },
        {
            "url": f"{base_url}/api",
            "expected_keys": ["message", "timestamp"]
        },
        {
            "url": f"{base_url}/health",
            "expected_keys": ["status", "service", "timestamp"]
        },
        {
            "url": f"{base_url}/metrics",
            "expected_keys": ["service", "version", "timestamp"]
        }
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        print()
        if test_endpoint(**test):
            passed += 1
        time.sleep(1)
    
    print()
    print("=" * 50)
    print(f"Tests passed: {passed}/{total}")
    
    if passed == total:
        print("🎉 All tests passed!")
        return 0
    else:
        print("❌ Some tests failed!")
        return 1

if __name__ == "__main__":
    exit(main())