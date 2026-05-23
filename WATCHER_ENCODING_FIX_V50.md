# V50 Watcher Encoding Fix

This version fixes the PowerShell parser error caused by Korean Y/N tokens being corrupted on Windows.

Broken line example:
if ($answer -in @("Y","y","YES","yes","??,"??)) {

V50 changes:
- tools/watch-downloads.ps1 is ASCII-safe.
- tools/deploy-latest.ps1 is ASCII-safe.
- Y/N confirmation now accepts Y or YES only.
- PowerShell scripts are saved with UTF-8 BOM for Windows PowerShell compatibility.

How to apply:
1. Upload/deploy this V50 ZIP normally, or
2. Replace only these files:
   - tools/watch-downloads.ps1
   - tools/deploy-latest.ps1
   - tools/start-watcher.bat
   - tools/start-watcher-nopush.bat
   - tools/deploy-latest.bat

Then run:
tools\start-watcher.bat
