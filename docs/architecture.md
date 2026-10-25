# Architecture and Operations Design

**Status:** design document. This does not claim production deployment or load-test evidence.

## 1. Architecture
```text
Git push / reviewed change
        |
        v
CI: validate -> build once -> SBOM/security scan -> sign -> immutable digest
        |
        v
Artifact registry ----> GitOps desired-state repository
                              |
                       pull-based reconciler
                              |
                 Kubernetes cluster (shared ring)
                    |        |         |
                  API      Workers   Observability
                    |        |
                  Redis ---- Queue
                    |
               PostgreSQL
                              |
              staged promotion: dev -> staging -> prod
                              |
               dedicated tenant stacks / region rings
```
The same image digest is promoted between environments; environment-specific configuration is injected at deploy time. Provider-specific infrastructure differs behind a platform interface.

## 2. Key decisions (and alternatives rejected)
1. **Kubernetes workload API for portability.** Rejected provider-specific container runtime APIs as the primary deployment contract because they increase lock-in. Cloud load balancers, IAM, storage classes and managed database services remain non-portable adapters.
2. **Build once and promote by digest.** Rejected rebuilding separately in each environment because that can produce different artifacts.
3. **Progressive canary rollout for API.** Start at 5%, then 25%, 50%, 100%, with at least 10 minutes or a meaningful request sample per stage. Gate on 5xx rate, p95 latency, readiness and saturation. If thresholds breach, stop promotion and restore the previous digest. This requires a traffic controller/service mesh or ingress that supports weighted routing.
4. **Worker rollout with drain.** Stop accepting new jobs, finish in-flight jobs within the 60-second job bound, then terminate. Rejected immediate termination because it risks duplicate/lost work. Queue processing should be idempotent and use acknowledgements/visibility timeouts.
5. **Expand/contract database migrations.** Add backward-compatible schema first, deploy compatible app, backfill, then remove old schema only after all old versions are gone. A non-backward-compatible migration requires a maintenance/compatibility plan; app rollback alone may not reverse schema changes.
6. **Managed data services in production.** Rejected single-Pod database/Redis as production architecture because it lacks HA and durable backup guarantees. The manifests in this repo are demo-only.
7. **GitOps pull model for production.** Cluster reconciles approved desired state from Git; reduces direct cluster credentials in CI. A pipeline-push model is simpler for a small demo but expands CI credential blast radius.

## 3. SLOs and rollout gates
- Shared availability objective: 99.9%; dedicated: 99.95%.
- API p95 latency target: <400 ms.
- Alert on sustained 5xx increase, p95 >400 ms, unavailable replicas, queue age/depth growth, database connection saturation, failed backups and error-budget burn.
- Rollout gate must compare candidate metrics to baseline and stop on any SLO breach. Automatic rollback is **designed, not tested** in this starter.

## 4. Scaling model
- Baseline: 150 req/s; peak: 2,250 req/s (15x).
- Do not infer pod counts from request rate alone. Benchmark one API replica to obtain sustainable throughput at p95 <400 ms, then estimate `replicas = ceil(2250 / measured_safe_rps_per_replica)`, add headroom and verify database connection limits.
- Scale API on CPU plus request/concurrency metrics; scale workers on queue depth and oldest-job age, not CPU alone.
- HPA alone may not add nodes fast enough; configure cluster autoscaler/node provisioning and pre-warm capacity for a <5-minute target. Scale-down must respect PodDisruptionBudgets and worker drain.
- No 15x test has been run.

## 5. Tenancy and data residency
- Shared stack first; dedicated tenant stacks introduced through a reviewed declarative change.
- Provisioning target <30 minutes is a goal, not verified.
- EU tenants must use EU-region compute, storage, backups, logs and keys; enforce region policy and test data flows. US-West/US-East failover requires explicit replication, RPO/RTO and residency review; not implemented here.
- Fleet rollout should proceed by ring and halt globally on a failed health/metric gate.

## 6. Security
- No secrets in Git or container images. Use cloud secret manager / workload identity in production.
- Scan dependencies and images; generate SBOM; sign image and verify signature at admission.
- Pin images by digest, use least-privilege IAM, network policies, TLS, non-root containers and read-only filesystems where compatible.
- CI workflow in this repository is a template and has not been executed against the real app.

## 7. Recovery and runbooks
### Bad release
1. Stop further promotion.
2. Compare health, 5xx, p95 and resource metrics against baseline.
3. Restore the previous known-good image digest.
4. Confirm readiness and error rate recovery.
5. If schema changed, follow the migration-specific recovery plan; do not assume binary rollback reverses DB changes.

### Worker queue backlog
1. Check queue depth and oldest-job age.
2. Check worker errors, Redis health and database connection saturation.
3. Scale workers within database connection limits.
4. Confirm graceful drain and idempotent retries; alert on poison jobs.

### Database restore
1. Restore backup into an isolated environment.
2. Validate schema, row counts and application read checks.
3. Record achieved RPO/RTO and approval before cutover.
4. A restore test is not yet performed.

## 8. Cost and limitations
Budget cap: USD 9,000/month baseline and USD 16,000/month peak, as specified by the assignment. Actual cost requires provider, region, traffic, database size, retention and egress assumptions; this starter does not assert a verified bill of materials. With the user's very limited short-term budget, do not create EKS, NAT gateways or managed databases merely to obtain a screenshot. Use local kind/k3d and documentation for the demo, and label cloud failover/15x scale as design-only.

## 9. 90-day roadmap
- **Days 1–30:** provision one cloud target, remote state/locking, CI image build + scan + signature, dev/staging environments, secrets integration.
- **Days 31–60:** GitOps, canary traffic shifting, automated metric gates/rollback, worker draining, database migration checks, SLO dashboards and alert tests.
- **Days 61–90:** second provider, dedicated tenant provisioning, EU residency policy tests, 15x load test, restore/failover drills, cost optimization and evidence package.

## 10. Top risks
1. Unknown app image/runtime and configuration contract.
2. Non-backward-compatible database migrations.
3. Insufficient measured capacity or database connection headroom at 15x.
4. Cross-region failover conflicting with data residency and RPO/RTO.
5. Unverified rollback/restore and cloud-specific dependencies.
