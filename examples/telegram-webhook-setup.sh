#!/bin/bash
#
# Set up Telegram webhook for Hermes Agent running on OpenShift
#
# Usage:
#   ./telegram-webhook-setup.sh <bot-token> <webhook-url>
#
# Example:
#   ./telegram-webhook-setup.sh 123456:ABC-DEF... https://hermes-agent-hermes.apps.your-cluster.com/telegram

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <bot-token> <webhook-url>"
    echo ""
    echo "Example:"
    echo "  $0 123456:ABC-DEF... https://hermes-agent-hermes.apps.your-cluster.com/telegram"
    exit 1
fi

BOT_TOKEN="$1"
WEBHOOK_URL="$2"

echo "Setting Telegram webhook..."
echo "  Bot token: ${BOT_TOKEN:0:10}..."
echo "  Webhook URL: $WEBHOOK_URL"

# Set webhook
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/setWebhook" \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"${WEBHOOK_URL}\"}")

echo ""
echo "Response:"
echo "$RESPONSE" | python3 -m json.tool

# Check if successful
if echo "$RESPONSE" | grep -q '"ok":true'; then
    echo ""
    echo "✓ Webhook configured successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Create Kubernetes secret with bot token:"
    echo "   oc create secret generic telegram-token \\"
    echo "     --from-literal=TELEGRAM_BOT_TOKEN=$BOT_TOKEN \\"
    echo "     -n hermes"
    echo ""
    echo "2. Update Hermes deployment to use secret:"
    echo "   oc set env deployment/hermes-agent \\"
    echo "     --from=secret/telegram-token \\"
    echo "     -n hermes"
    echo ""
    echo "3. Send a message to your bot to test!"
else
    echo ""
    echo "✗ Failed to set webhook"
    exit 1
fi
