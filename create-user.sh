#!/usr/bin/env bash
# create-overleaf-admin.sh
# Creates an admin user in a running Overleaf (ShareLaTeX) pod

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -e, --email EMAIL     Email address of the admin user to create (required)
  -h, --help            Show this help message and exit

Example:
  ./create-overleaf-admin.sh --email admin@example.com
EOF
}

# Default values
ADMIN_EMAIL=""

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--email)
      ADMIN_EMAIL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ADMIN_EMAIL" ]]; then
  echo "Error: --email is required"
  usage
  exit 1
fi

echo "Waiting for a ready ShareLaTeX (Overleaf) pod..."

POD=""
for i in $(seq 1 30); do
  POD=$(kubectl get pods -l app=sharelatex -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  if [[ -n "$POD" ]]; then
    STATUS=$(kubectl get pod "$POD" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' || true)
    if [[ "$STATUS" == "True" ]]; then
      echo "Pod $POD is Ready"
      break
    fi
  fi
  echo "Pod not ready yet, retrying..."
  sleep 2
done

if [[ -z "$POD" ]]; then
  echo "Error: could not find a ready sharelatex pod"
  exit 1
fi

echo "Running create-user.js in pod $POD..."
echo "Creating admin user with email: $ADMIN_EMAIL"

kubectl exec "$POD" --container sharelatex -- \
  sh -c "cd /overleaf/services/web && \
         node /overleaf/services/web/modules/server-ce-scripts/scripts/create-user.js --email '$ADMIN_EMAIL' --admin" \
  | grep -A100 -i "Successfully created"

