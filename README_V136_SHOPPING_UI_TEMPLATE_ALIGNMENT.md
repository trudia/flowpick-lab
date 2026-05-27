# V136 Shopping UI Template Alignment

- Aligned `rainy-season-shoe-odor-dryer-dehumidifier` with the existing TrendFlow shopping article UI.
- Replaced the non-standard article wrapper, kicker, hero figure, and affiliate notice block with the established shopping UI shell.
- Strengthened `scripts/validate-shopping-post.ps1` so future shopping posts fail validation if they use the wrong article shell.
- Documented the required shopping UI markers in the Coupang Partners API workflow and candidate template.
- Updated sitemap, version, and deploy check for this patch.

Validation target:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-shopping-post.ps1 -Slug "rainy-season-shoe-odor-dryer-dehumidifier" -Version 136
```
