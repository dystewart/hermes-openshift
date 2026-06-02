# Moved to manifests/

The deployment manifests have been reorganized to follow Kustomize conventions.

**Please use:** [`manifests/`](../manifests/)

All deployment files are now in the `manifests/` directory:
- [`07-hermes-deployment.yaml`](../manifests/07-hermes-deployment.yaml) - Hermes Agent deployment
- See [`manifests/`](../manifests/) for complete deployment

To deploy:
```bash
oc apply -k manifests/
```
