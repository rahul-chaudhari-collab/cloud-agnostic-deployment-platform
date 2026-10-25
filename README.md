# Cloud-Agnostic, Automated, Zero-Downtime Deployment Platform

**Submission status:** starter implementation + design. Read the status labels carefully. Any component not executed and evidenced is marked **DESIGNED / NOT VERIFIED**. Do not present unrun tests as successful.

## 1. Scope
This repository provides a reviewable baseline for the ImmverseAI DevOps assignment:
- Kubernetes manifests for an API, worker, Redis and PostgreSQL.
- GitHub Actions CI workflow for validation, image build, vulnerability scan and image digest output.
- Terraform starter for AWS networking/compute is intentionally not auto-applied.
- Architecture and operational runbooks for progressive delivery, database migrations, scaling, recovery, tenancy and cost.
- Local Kubernetes target can be kind or k3d; a second cloud target requires provider-specific modules and validation.

## 2. Application contract
The supplied application is treated as a black box:
- API listens on `8080`; endpoints `/healthz`, `/readyz`, `/metrics`.
- Worker consumes Redis jobs; jobs can take up to 60 seconds.
- PostgreSQL migrations run at startup; some migrations are not backward-compatible.
- Redis queue and PostgreSQL persistence are required.

The actual application image and its environment variable contract were not supplied in this starter. Replace `REPLACE_WITH_REGISTRY/immverse-api:REPLACE_WITH_TAG` and worker image with the actual image before deployment. Secret values must be provided by a secrets manager, not committed to Git.

## 3. What is implemented vs designed
| Area | Status |
|---|---|
| Kubernetes resource templates | Implemented as templates; not runtime-tested |
| CI workflow | Implemented as a workflow template; requires repository secrets and a real application Dockerfile |
| Terraform | Starter/design only; not applied |
| Progressive delivery and automatic rollback | Designed in `docs/architecture.md`; not executed |
| 15x load test, zero-error evidence, restore test | Not run; must not be claimed |
| Multi-cloud dedicated tenant and EU data residency | Design only |
| Cost estimate and 90-day roadmap | In architecture document |

## 4. Quick path
1. Create a GitHub repository and upload this folder's contents.
2. Replace image placeholders and add the real app source/build context if supplied.
3. Review `k8s/` and `docs/architecture.md`.
4. Use `kubectl apply --dry-run=client -f k8s/` only after installing kubectl; validate each file separately if the local client rejects directory input.
5. Do not apply Terraform or create paid AWS resources without reviewing the plan and cost.
6. Add screenshots/logs only for tests actually performed.

## 5. Interview honesty
Be ready to explain which items are working code, which are design decisions, and which remain unverified. This repo intentionally avoids claiming that production-scale availability, 15x scaling, failover, or rollback was proven.
