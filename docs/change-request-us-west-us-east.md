# Change Request Addendum: Second Dedicated Stack

**Status:** Proposed — not implemented or tested
**Scope:** Provision a second dedicated tenant stack on a different cloud provider, with US-West as the primary region and US-East as the failover region.

## 1. Objective

Extend the existing cloud-agnostic platform to support a dedicated tenant stack on a second cloud provider. The design must support regional failover while keeping tenant resources isolated and protecting application availability and data integrity.

## 2. Proposed Architecture

* **Cloud provider:** Select a second provider after reviewing service compatibility, pricing, and operational requirements.
* **Primary:** US-West region hosts the dedicated tenant's application workloads.
* **Failover:** US-East region maintains the infrastructure and data replication required for recovery.
* **Deployment:** Reuse the platform's Kubernetes workload templates and provider-specific infrastructure modules.
* **Traffic management:** Use health-checked regional routing to direct traffic to US-East when US-West is unavailable.

## 3. Data Replication and Recovery

PostgreSQL replication and Redis queue recovery must be designed according to the application's consistency requirements. Before release, define and approve the recovery point objective (RPO) and recovery time objective (RTO). Validate replication lag, queue recovery, duplicate-job handling, and database promotion. Prevent split-brain writes by ensuring only the authorized primary accepts writes during failover.

## 4. Security and Operations

Use separate tenant-scoped identities, least-privilege access, managed secrets, encryption in transit and at rest, and region-specific monitoring. Restrict administrative access and log all failover operations. Confirm that backups can be restored in the recovery region and that required dependencies are available there.

## 5. Rollout and Acceptance Criteria

1. Review provider-specific differences, cost, security, and data replication.
2. Provision the secondary dedicated stack through reviewed Infrastructure as Code.
3. Validate application health, network access, secrets, and observability.
4. Run a controlled failover and failback exercise.
5. Record measured RPO/RTO, data consistency, recovery evidence, and monthly cost.
6. Obtain service-owner approval before production release.

**Release gate:** Do not declare this change production-ready until failover, failback, backup restoration, and data-consistency tests pass.

**Current limitation:** This is a proposed change request only. The second cloud stack and US-West/US-East failover have not been provisioned or tested.
