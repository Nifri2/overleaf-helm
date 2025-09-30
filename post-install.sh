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
  tlmgr install amsmath amsfonts graphics csquotes unicode-math breqn physics \
    algorithm2e algorithms algpseudocodex \
    geometry fancyhdr setspace parskip titlesec sectsty microtype \
    booktabs makecell \
    pgf float placeins xcolor \
    lipsum caption csquotes hyperref pdfpages todonotes \
    siunitx enumitem fontspec \
    babel-english babel-german babel-french babel-spanish babel-italian \
    footmisc algorithmicx pdflscape

echo "All selected LaTeX packages installed successfully!"
