#!/usr/bin/env python3
"""
Simple test runner script for local testing
"""

import os
import sys
import subprocess

def run_tests():
    """Run the test suite"""
    print("🧪 Running Liatrio Demo API Tests...")
    print("=" * 50)
    
    # Change to app directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # Install test dependencies if needed
    print("📦 Installing test dependencies...")
    subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=False)
    
    # Run pytest
    print("\n🚀 Executing tests...")
    result = subprocess.run([
        sys.executable, "-m", "pytest", 
        "test_app.py", 
        "-v",
        "--tb=short",
        "--cov=app",
        "--cov-report=term-missing"
    ])
    
    if result.returncode == 0:
        print("\n✅ All tests passed!")
    else:
        print("\n❌ Some tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    run_tests()