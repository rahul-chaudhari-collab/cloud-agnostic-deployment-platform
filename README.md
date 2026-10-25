# Cloud-Agnostic, Automated, Zero-Downtime Deployment Platform

**Submission status:** Starter implementation + design. Any component not executed and evidenced is marked **DESIGNED / NOT VERIFIED**. Do not present unrun tests as successful.

## 1. Scope

This repository provides a reviewable baseline for the ImmverseAI DevOps assignment:

- Kubernetes manifests for the API, worker, Redis, and PostgreSQL.
- GitHub Actions workflow for repository checks and Kubernetes manifest structural validation.
- Conditional application image build and vulnerability scan template.
- Terraform starter for AWS networking/compute; infrastructure is not automatically applied.
- Architecture and operational documentation for progressive delivery, database migrations, scaling, recovery, tenancy, and cost.
- Local Kubernetes validation using Minikube; kind/k3d and a second cloud target require additional validation and implementation.

## 2. Application Contract

The supplied application is treated as a black box:

- API listens on port `8080` and exposes `/healthz`, `/readyz`, and `/metrics`.
- Worker consumes Redis jobs; jobs can take up to 60 seconds.
- PostgreSQL migrations run at startup; some migrations are not backward-compatible.
- Redis queue and PostgreSQL persistence are required.

The actual application source and its environment variable contract were not supplied in this starter. Replace the API and worker image placeholders with real image references before deployment. Supply secrets through an approved secrets manager; never commit secret values to Git.

## 3. Implementation and Verification Status

| Area | Status |
|---|---|
| Kubernetes manifests | Templates created; structural validation passed |
| Kubernetes API server dry-run | Worker manifest accepted by server-side dry-run |
| Local Kubernetes | Minikube test cluster and generic NGINX test workload validated |
| GitHub Actions | Repository and Kubernetes manifest validation workflow passed |
| Application image build and scan | Conditional template; actual application build and scan not verified |
| Terraform | Starter/design only; not applied |
| Progressive delivery and automatic rollback | Designed in `docs/architecture.md`; not executed |
| Worker graceful job draining | Shutdown configuration documented; application behavior not verified |
| Database migration procedure | Documented in `docs/database-migration-runbook.md`; not executed against a live database |
| 15x load test and zero-error evidence | Not run |
| Database backup and restore test | Not performed |
| Multi-cloud dedicated tenant and EU data residency | Design only; not validated |
| Production failover | Not implemented or tested |

A successful manifest validation does not prove that the actual application runs correctly or meets production SLOs.

## 4. Repository Guide
OAOAOAOAOAOAOAOAOAOA
OAOAOAOAOAOAOAOAOAOA| Path | Purpose |
|---|---|
| `.github/workflows/ci.yml` | CI validation and conditional image build/scan template |
| `.github/scripts/validate-k8s.sh` | Basic structural validation of Kubernetes YAML manifests |
| `k8s/api.yaml` | API Deployment, Service, and PodDisruptionBudget |
| `k8s/worker.yaml` | Worker Deployment and shutdown configuration |
| `k8s/data-services.yaml` | Demo-only Redis and PostgreSQL resources |
| `k8s/secrets.example.yaml` | Example secret configuration; do not put real credentials in Git |
| `terraform/README.md` | Terraform starter documentation |
| `docs/architecture.md` | Architecture decisions, rollout strategy, SLOs, risks, costs, and roadmap |
| `docs/database-migration-runbook.md` | PostgreSQL expand/contract migration and recovery procedure |
| `docs/evidence.md` | Evidence of checks actually performed and outstanding limitations |

## 5. Quick Validation

Run the local structural validator:

```bash
bash .github/scripts/validate-k8s.sh

Validate a manifest against the configured Kubernetes API server without applying it:

kubectl apply --dry-run=server -f k8s/worker.yaml

The server-side dry-run requires a reachable cluster and validates only the supplied manifest. It does not deploy the workload or verify application behavior.

Before deploying:

Replace image placeholders with actual immutable image references.
Review all Kubernetes manifests and secret references.
Configure the required secrets through an approved secrets manager.
Review the Terraform plan and estimated cloud cost before provisioning infrastructure.
Confirm database persistence, backups, migration compatibility, and recovery procedures.
Capture evidence only for tests actually performed.
6. Production Readiness Gaps

The following work remains before production use:

Provider-specific infrastructure modules and a second cloud deployment target.
Managed, durable PostgreSQL and Redis-compatible services with appropriate availability, security, and backup configuration.
Real application build, security scan, immutable image digest promotion, and environment-specific deployment automation.
Progressive traffic shifting with metric-based promotion and automated rollback.
Application-supported graceful shutdown and worker job draining.
Automated database migration checks, backup validation, and restore drills.
Load testing, SLO dashboards, alert validation, tenant isolation, and regional failover testing.

