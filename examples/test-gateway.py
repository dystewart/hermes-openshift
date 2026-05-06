#!/usr/bin/env python3
"""
Test HTTP gateway connection to Hermes Agent.

Usage:
    # From within cluster:
    python3 test-gateway.py http://hermes-agent.hermes.svc.cluster.local:8080

    # From external (if Route is deployed):
    python3 test-gateway.py https://hermes-agent-hermes.apps.your-cluster.com
"""

import json
import sys
import requests


def test_health(base_url):
    """Test health endpoint."""
    url = f"{base_url}/health"
    print(f"Testing health endpoint: {url}")

    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        print(f"✓ Health check: {response.json()}")
        return True
    except Exception as e:
        print(f"✗ Health check failed: {e}")
        return False


def test_api(base_url):
    """Test API endpoint with a simple message."""
    url = f"{base_url}/api"
    print(f"\nTesting API endpoint: {url}")

    payload = {
        "message": "Hello Hermes! Can you introduce yourself?",
        "user_id": "test-user",
        "platform": "api"
    }

    try:
        response = requests.post(url, json=payload, timeout=30)
        response.raise_for_status()
        result = response.json()

        print(f"✓ API response:")
        print(f"  User: {payload['message']}")
        print(f"  Agent: {result.get('response', result)[:200]}...")
        return True
    except Exception as e:
        print(f"✗ API test failed: {e}")
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 test-gateway.py <base-url>")
        print("Example: python3 test-gateway.py http://hermes-agent.hermes.svc.cluster.local:8080")
        sys.exit(1)

    base_url = sys.argv[1].rstrip('/')

    print(f"Testing Hermes Agent gateway at: {base_url}\n")

    # Test health first
    if not test_health(base_url):
        print("\n✗ Health check failed - gateway may not be running")
        sys.exit(1)

    # Test API
    if test_api(base_url):
        print("\n✓ All tests passed!")
    else:
        print("\n⚠ API test failed - gateway is running but API endpoint may not be configured")
        sys.exit(1)


if __name__ == "__main__":
    main()
