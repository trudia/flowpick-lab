# V137 Coupang Tracking Tag Validation

- Added a default `ExpectedTrackingTag` guard to `scripts/validate-shopping-post.ps1`.
- The shopping validator now fails if Coupang affiliate links are missing `lptag=AF3446366` or use another tracking tag.
- Updated the Coupang Partners API workflow and candidate template to record the verified TrendFlow tracking tag.
- Updated version and deploy check for this patch.

Validation target:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-shopping-post.ps1 -Slug "rainy-season-shoe-odor-dryer-dehumidifier" -Version 137
```
