# V56 Backup Validation Skip Fix

This update fixes a validation failure where deploy-update.ps1 scanned `.trendflow-backups`
after creating a backup and reported old broken files inside the backup folder.

Example:
.trendflow-backups\20260523-142946\minimal-space.html -> ../assets/minimal-desk.svg

Cause:
The skip logic for `.trendflow-backups` was not robust enough on Windows path handling.

Fix:
- deploy-update.ps1 now normalizes paths and reliably skips:
  - .git
  - .trendflow-backups
  - .trendflow-state
  - .trendflow-logs
  - node_modules
- verify-site.ps1 uses the same skip logic.
