# V54 No-Param Watcher Fix

This fixes a PowerShell parser error at:

[string]$DownloadsPath = "$env:USERPROFILE\Downloads"

Cause:
On some Windows PowerShell environments, the param() block in watcher scripts can be parsed incorrectly after encoding/path handling.

Fix:
- tools/watch-downloads.ps1 no longer uses param().
- tools/start-watcher.bat passes settings through environment variables.
- This avoids the invalid assignment parser error.

Apply:
1. Close the old watcher window.
2. Extract this patch.
3. Run INSTALL_AUTOMATION_FIX.bat.
4. Run tools\start-watcher.bat again.
