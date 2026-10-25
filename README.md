# Cloud-Agnostic, Automated, Zero-Downtime Deployment Platform

***Project Overview: This repository contains the initial implementation and architecture design for a cloud-agnostic deployment platform. It includes Kubernetes configuration templates, a CI workflow, and infrastructure documentation. Components are identified according to their current implementation and validation status.

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
1. Review the repository structure and the configuration files.
2. Configure the actual API and worker container images.
3. Configure the required application secrets securely.
4. Validate the Kubernetes manifests and CI workflow before deployment.
5. Review the Terraform plan and estimated cloud costs before creating infrastructure.
6. Record evidence only for tests that have actually been executed.
   
## 5. Implementation Status
The repository currently contains Kubernetes configuration templates, a CI workflow template, and infrastructure and architecture documentation.
The next steps are to validate the deployment workflow, test rollback behavior, evaluate autoscaling, and verify recovery procedures.
Components that have not been tested in a running environment will be identified as pending validation.
