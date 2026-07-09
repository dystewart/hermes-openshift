# Hermes Agent on Red Hat OpenShift

Deploy [Hermes Agent](https://github.com/NousResearch/hermes-agent), the self-improving AI agent with built-in learning loop, on Red Hat OpenShift.

**What this provides:**
- UBI 9-based container optimized for OpenShift
- Multi-platform messaging gateway (Telegram, Discord, Slack, HTTP API)
- OpenShift Security Context Constraint (`restricted-v2`) compliant
- Kustomize-based deployment manifests
- Hermes GUI dashboard
- Persistent storage for skills, memories, and user models
- Integration ready for vLLM or any OpenAI-compatible API

## Architecture

**Components:**
- **Agent Core** - Learning loop with skills system and user modeling
- **Persistent Storage** - SQLite database with FTS5 full-text search
- **LLM Integration** - Works with any OpenAI-compatible API

## Quick Start

### Prerequisites

- Red Hat OpenShift 4.x cluster
- `oc` CLI authenticated to cluster
- OpenAI API key (or compatible API endpoint)

**NOTE** The example manifests in this repository are configured to run the Hermes agent using a codex api key

### Deploy

```bash
# Clone repository
git clone https://github.com/aicatalyst-team/hermes-openshift
cd hermes-openshift

# Create OpenAI API key secret & creds for hermes web gui
cat > hermes.env <<'EOF'
OPENAI_API_KEY=your-openai-codex-key
HERMES_DASHBOARD_BASIC_AUTH_USERNAME={REPLACE}
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD={REPLACE}
HERMES_DASHBOARD_BASIC_AUTH_SECRET={REPLACE; use openssl rand -base64 32}
EOF

# Consume the api key in a secret
oc create secret generic openai-api-key \
  --from-file=.env=hermes.env \
  -n hermes

# Deploy Hermes Agent
oc apply -k manifests/

# Wait for pods to be ready
oc get pods -n hermes -w
```

**Expected output:**
```
NAME                            READY   STATUS    RESTARTS   AGE
hermes-agent-7d9f8b5c4d-x9z2k   1/1     Running   0          30s
```

Get the route to your Hermes dashboard:

```
echo "https://$(oc -n hermes get route hermes-dashboard -o jsonpath='{.spec.host}')"
```

Log in using `HERMES_DASHBOARD_BASIC_AUTH_USERNAME` and `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD`

## Usage

### CLI Access

```bash
# Get shell in Hermes pod
POD=$(oc get pods -n hermes -l app=hermes-agent -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -n hermes -- /opt/hermes/venv/bin/python -m hermes_cli.main

# Start conversation
> Hello! What can you help me with?
```

### Messaging Platforms

Add platform credentials as secrets:

```bash
# Telegram
oc create secret generic hermes-secrets \
  --from-literal=TELEGRAM_BOT_TOKEN=your-telegram-token \
  -n hermes

# Discord
oc create secret generic hermes-secrets \
  --from-literal=DISCORD_BOT_TOKEN=your-discord-token \
  --dry-run=client -o yaml | oc apply -f -

# Update deployment to use secrets
oc set env deployment/hermes-agent --from=secret/hermes-secrets -n hermes
```

**Set up Telegram webhook:**

```bash
# Get route URL
WEBHOOK_URL=$(oc get route hermes-agent -n hermes -o jsonpath='{.spec.host}')

# Configure webhook
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -d "url=https://${WEBHOOK_URL}/telegram"
```

## Manifests

| File | Description |
|------|-------------|
| `01-namespace.yaml` | Creates `hermes` namespace |
| `02-hermes-storage.yaml` | 10Gi PVC for agent data |
| `03-hermes-config.yaml` | LLM configuration (model, provider, endpoint) |
| `04-hermes-deployment.yaml` | Deployment with security contexts and health probes |
| `05-hermes-service.yaml` | ClusterIP service on port 8080 |
| `06-hermes-env.yaml` | Environment variable ConfigMap |
| `kustomization.yaml` | Kustomize manifest aggregator |

## Building Custom Image

OpenShift requires Red Hat Universal Base Image (UBI) containers. The challenge is that Hermes needs Node.js 20.x for its Vite-based web UI, however UBI 9 ships with Node.js 16.x. The solution is to install Node.js 20.x from the NodeSource RPM repository.

The repository includes `Dockerfile.ubi` for building a UBI 9-based image:

```bash
# Build image
podman build -f Dockerfile.ubi -t quay.io/your-org/hermes-agent:latest --platform linux/amd64 .

# Push to registry
podman push quay.io/your-org/hermes-agent:latest

# Update deployment
# Edit manifests/04-hermes-deployment.yaml and change image line
```

**Build features:**
- UBI 9 minimal base with Python 3.11
- Node.js 20.x from NodeSource (required for Vite)
- Web dashboard and TUI built from source
- OpenShift arbitrary UID support (runs as random UID, GID 0)
- `restricted-v2` SCC compliant

## Examples

The `examples/` directory contains:

- **`cli-usage.sh`** - CLI access examples
- **`telegram-webhook-setup.sh`** - Telegram integration script
- **`test-gateway.py`** - WebSocket testing script

## Resources

- **Hermes Agent:** https://github.com/NousResearch/hermes-agent
- **Documentation:** https://hermes-agent.nousresearch.com/docs/
- **Skills Hub:** https://agentskills.io
- **Red Hat OpenShift:** https://www.redhat.com/en/technologies/cloud-computing/openshift
