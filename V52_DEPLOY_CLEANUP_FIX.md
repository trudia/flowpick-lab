# V52 Deploy Cleanup Fix

This version fixes a deploy failure caused by stale root HTML files left in the local Git repository.

Example failure:
- minimal-space.html -> ../assets/minimal-desk.svg
- minimal-space.html -> ../assets/one-room.svg
- minimal-space.html -> ../assets/cable-storage.svg

Cause:
Older root HTML files were not removed before copying the new site. The deploy validator scanned the whole repository and found old broken image references.

Fix:
- deploy-update.ps1 now removes stale root *.html files before copying the new ZIP.
- deploy-update.ps1 ignores .git, .trendflow-backups, .trendflow-state, .trendflow-logs while validating.
- deploy-update.ps1 messages are now ASCII-safe to avoid Korean console encoding issues.
- watcher waits 30 seconds after failed deploy before retrying the same ZIP.

Apply this update, then run:
tools\start-watcher.bat

If the same failed V51 zip keeps being detected, delete it from Downloads or deploy this V52 zip.
