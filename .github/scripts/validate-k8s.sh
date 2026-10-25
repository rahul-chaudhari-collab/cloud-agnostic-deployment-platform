#!/usr/bin/env bash
set -euo pipefail

echo "Validating Kubernetes manifest files..."

for file in k8s/*.yaml; do
  if [ ! -f "$file" ]; then
    echo "ERROR: No Kubernetes YAML files found."
    exit 1
  fi

  echo "Checking: $file"

  python - "$file" <<'PY'
import sys
import yaml

path = sys.argv[1]

with open(path, encoding="utf-8") as f:
    documents = [doc for doc in yaml.safe_load_all(f) if doc is not None]

if not documents:
    raise SystemExit(f"ERROR: {path} contains no YAML documents")

for doc in documents:
    if not isinstance(doc, dict):
        raise SystemExit(f"ERROR: {path} contains a non-object YAML document")

    for field in ("apiVersion", "kind", "metadata"):
        if field not in doc:
            raise SystemExit(f"ERROR: {path} is missing required field: {field}")

    if not isinstance(doc["metadata"], dict) or not doc["metadata"].get("name"):
        raise SystemExit(f"ERROR: {path} has missing metadata.name")

print(f"PASS: {path}")
PY
done

echo "Kubernetes manifest structural validation completed."
