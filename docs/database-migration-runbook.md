# PostgreSQL Database Migration Runbook

## 1. Purpose

This runbook defines a safe migration process for PostgreSQL schema changes when multiple application versions may run simultaneously during a rolling deployment.

**Status:** Operational procedure documented; not executed against a live application or production database.

## 2. Pre-Migration Checks

Before approving a migration:

1. Review the migration SQL and identify incompatible schema changes.
2. Verify that the migration has been tested against a representative database.
3. Confirm that a recent backup exists and that the restore procedure is documented.
4. Check database connection capacity, disk capacity, replication health, and active long-running queries.
5. Define success criteria, abort thresholds, and the recovery procedure.
6. Confirm that the application version being deployed supports the transitional schema.

Do not proceed if the migration could cause data loss and a recovery strategy has not been approved.

## 3. Expand/Contract Procedure

### Phase A: Expand

1. Add new tables, columns, or indexes without removing fields used by the current application.
2. Prefer nullable columns or safe defaults where appropriate.
3. For large tables, evaluate online or concurrent index creation to reduce locking.
4. Verify that the existing application continues to operate with the expanded schema.

### Phase B: Application Compatibility

1. Deploy an application version compatible with both the old and new schema.
2. Validate readiness, error rate, p95 latency, database connections, and application logs.
3. Stop rollout if agreed health thresholds are breached.
4. Keep the previous application image digest available for rollback.

### Phase C: Backfill

1. Backfill existing records in bounded batches.
2. Make the backfill idempotent so it can safely resume.
3. Monitor database load, lock contention, replication lag, and application latency.
4. Verify row counts and data consistency before proceeding.

### Phase D: Switch Reads and Writes

1. Enable the new schema path through a reviewed configuration or feature flag, if supported.
2. Compare old and new results where practical.
3. Confirm that all active application versions can operate safely during the transition.
4. Keep the old schema available until compatibility and data checks pass.

### Phase E: Contract

1. Confirm that no running application version depends on the old schema.
2. Obtain approval for the destructive migration.
3. Remove obsolete columns, tables, or compatibility code in a separate release.
4. Verify application health and data integrity after the change.

Never combine an irreversible schema removal with the initial application rollout unless a specifically reviewed migration plan requires it.

## 4. Failure and Recovery

### Application deployment fails

* Stop further promotion.
* Route traffic back to the previous known-good application version or image digest.
* Verify application health and database connectivity.
* Do not automatically reverse database changes unless the migration has a tested reversal procedure.

### Migration fails

* Stop dependent application rollout.
* Preserve migration logs and inspect the database state.
* Determine whether the migration is safe to retry or requires a forward fix.
* Obtain database-owner approval before manual repair or restoration.

### Data corruption or unrecoverable schema failure

* Follow the approved incident process.
* Determine the recovery point objective (RPO) and recovery time objective (RTO).
* Restore to an isolated environment first when feasible.
* Validate data integrity before authorizing production recovery.
* Consider writes performed after the backup when determining whether restoration is appropriate.

## 5. Validation and Evidence

Record the following for each production migration:

* Change request and approval.
* Application image digest.
* Migration identifier and version.
* Backup reference and recovery point.
* Pre- and post-migration health metrics.
* Data consistency checks.
* Rollout or rollback outcome.
* Incident notes and follow-up actions.

## 6. Limitations

This repository does not contain the actual application migration framework or production database credentials. The procedure is a design artifact, not evidence of a successful live migration, rollback, backup, or restore test. Those activities must be implemented and verified in the target environment.

