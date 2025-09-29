#!/usr/bin/env bash
# post-install.sh
# Updates tlmgr and installs common LaTeX packages for Overleaf CE

set -euo pipefail

echo "Starting TeX Live post-install setup..."

# Optional: wait for the Overleaf pod if you want to run this in Kubernetes
POD_NAME="${OVERLEAF_POD:-$(kubectl get pods -l app=sharelatex -o jsonpath='{.items[0].metadata.name}')}"

echo "Updating tlmgr in pod $POD_NAME..."
kubectl exec -it "$POD_NAME" --container sharelatex -- \
  tlmgr update --self

echo "Installing essential LaTeX packages..."
kubectl exec -it "$POD_NAME" --container sharelatex -- \
  tlmgr install \
    pgf caption xcolor geometry lipsum amsmath amsfonts fancyhdr hyperref \
    fontspec microtype enumitem titlesec sectsty mathtools booktabs \
    siunitx float todonotes setspace parskip \
    babel-german \
    babel-english \
    babel-french \
    babel-spanish \
    babel-italian

echo "All selected LaTeX packages installed successfully!"
