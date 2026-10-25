# Terraform starter — not applied

The assignment asks for cloud-agnostic infrastructure and a cloud + local target. A responsible implementation separates:
- `modules/`: reusable network/cluster/database building blocks
- `environments/dev`, `staging`, `prod`: configuration per environment
- provider-specific modules: AWS and a second provider
- local Kubernetes: kind/k3d manifests

**Not included as a working claim:** a fully tested EKS cluster, second-cloud cluster, remote backend, drift detection or production secrets integration. These require provider credentials, budget approval, backend setup and live validation. Before any apply, configure remote state with locking, run `terraform fmt -check`, `terraform validate`, and inspect `terraform plan`. Never commit state files or credentials.
