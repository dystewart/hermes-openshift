#!/bin/bash
#
# Example: Using Hermes Agent CLI from within OpenShift pod
#
# This script demonstrates how to interact with Hermes Agent running on OpenShift
# using the CLI interface.

set -e

NAMESPACE="hermes"

echo "Getting Hermes Agent pod..."
POD=$(oc get pods -n $NAMESPACE -l app=hermes-agent -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
    echo "✗ No Hermes Agent pod found in namespace $NAMESPACE"
    exit 1
fi

echo "✓ Found pod: $POD"
echo ""

# Example 1: Check Hermes version
echo "1. Checking Hermes version:"
oc exec -n $NAMESPACE $POD -- /opt/hermes/venv/bin/python -m hermes_cli.main --version
echo ""

# Example 2: Check current model configuration
echo "2. Checking model configuration:"
oc exec -n $NAMESPACE $POD -- /opt/hermes/venv/bin/python -m hermes_cli.main config show
echo ""

# Example 3: Interactive conversation (requires terminal)
echo "3. Starting interactive conversation..."
echo "   (This will give you a shell - type 'exit' to quit)"
echo ""
read -p "Press Enter to continue..."

oc exec -it -n $NAMESPACE $POD -- /opt/hermes/venv/bin/python -m hermes_cli.main

echo ""
echo "✓ Session ended"
