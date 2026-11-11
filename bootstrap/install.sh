#!/usr/bin/env bash
# Install Argo CD, then hand everything else to GitOps through the root application.
set -euo pipefail

ARGOCD_CHART_VERSION="${ARGOCD_CHART_VERSION:-7.7.0}"
here="$(cd "$(dirname "$0")" && pwd)"

helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update argo >/dev/null

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version "$ARGOCD_CHART_VERSION" \
  --values "$here/argocd-values.yaml" \
  --wait

kubectl apply -f "$here/root-app.yaml"

echo "Argo CD is syncing the platform. Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo
