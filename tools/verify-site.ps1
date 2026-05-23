param([string]$RepoPath = (Resolve-Path ".").Path)
$ErrorActionPreference = "Stop"
function Test-ImageReferences($Root){
  $missing=New-Object System.Collections.Generic.List[string]
  foreach($file in Get-ChildItem -LiteralPath $Root -Recurse -Filter "*.html" -File){
    $text=Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    foreach($m in [regex]::Matches($text,'<img[^>]+src="([^"]+)"')){
      $src=$m.Groups[1].Value
      if($src.StartsWith('http') -or $src.Contains('${') -or $src.StartsWith('/')){ continue }
      $full=[System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $src))
      if(-not(Test-Path -LiteralPath $full)){ $missing.Add($file.FullName.Replace($Root,'').TrimStart('\','/') + ' -> ' + $src) }
    }
  }
  return $missing
}
$RepoPath=[System.IO.Path]::GetFullPath($RepoPath)
Write-Host "TrendFlow 로컬 검증: $RepoPath" -ForegroundColor Cyan
$failed=$false
foreach($r in @('index.html','styles.css','version.txt','categories','assets')){
  if(Test-Path -LiteralPath (Join-Path $RepoPath $r)){ Write-Host "[OK] $r" -ForegroundColor Green } else { Write-Host "[MISS] $r" -ForegroundColor Red; $failed=$true }
}
$v=Join-Path $RepoPath 'version.txt'
if(Test-Path -LiteralPath $v){ Write-Host ('version.txt: ' + (Get-Content -LiteralPath $v -Encoding UTF8 | Select-Object -First 1)) -ForegroundColor Yellow }
$missing=Test-ImageReferences $RepoPath
if($missing.Count -gt 0){ Write-Host '누락 이미지 참조:' -ForegroundColor Red; $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }; $failed=$true } else { Write-Host '이미지 참조: OK' -ForegroundColor Green }
if($failed){ exit 1 } else { Write-Host '검증 통과' -ForegroundColor Green }
