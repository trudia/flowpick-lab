param(
  [Parameter(Mandatory=$true)][string]$ZipPath,
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$CommitMessage = "",
  [switch]$NoPush,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
function Write-Step($m){ Write-Host ""; Write-Host "==> $m" -ForegroundColor Cyan }
function Fail($m){ Write-Host ""; Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }
function Ensure-Command($c){ if(-not(Get-Command $c -ErrorAction SilentlyContinue)){ Fail "$c 명령을 찾을 수 없습니다." } }
function Copy-DirectoryContents($Source,$Destination){ Get-ChildItem -LiteralPath $Source -Force | ForEach-Object { $target=Join-Path $Destination $_.Name; Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force } }
function Test-ImageReferences($Root){
  $missing=New-Object System.Collections.Generic.List[string]
  $htmlFiles=Get-ChildItem -LiteralPath $Root -Recurse -Filter "*.html" -File
  foreach($file in $htmlFiles){
    $text=Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $matches=[regex]::Matches($text,'<img[^>]+src="([^"]+)"')
    foreach($m in $matches){
      $src=$m.Groups[1].Value
      if($src.StartsWith('http') -or $src.Contains('${') -or $src.StartsWith('/')){ continue }
      $full=[System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $src))
      if(-not(Test-Path -LiteralPath $full)){
        $rel=$file.FullName.Replace($Root,'').TrimStart('\','/')
        $missing.Add("$rel -> $src")
      }
    }
  }
  return $missing
}
function Get-VersionFrom($Root){ $v=Join-Path $Root 'version.txt'; if(Test-Path -LiteralPath $v){ return (Get-Content -LiteralPath $v -Encoding UTF8 | Select-Object -First 1) }; return '' }

Write-Step 'TrendFlow 자동 배포 시작'
$ZipPath=[System.IO.Path]::GetFullPath($ZipPath)
$RepoPath=[System.IO.Path]::GetFullPath($RepoPath)
if(-not(Test-Path -LiteralPath $ZipPath)){ Fail "ZIP 파일을 찾을 수 없습니다: $ZipPath" }
if(-not(Test-Path -LiteralPath $RepoPath)){ Fail "RepoPath를 찾을 수 없습니다: $RepoPath" }
if(-not(Test-Path -LiteralPath (Join-Path $RepoPath '.git'))){ Fail 'RepoPath가 Git 저장소가 아닙니다. GitHub 저장소 루트 폴더에서 실행하거나 -RepoPath를 지정하세요.' }
Ensure-Command 'git'
$timestamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$temp=Join-Path $env:TEMP "trendflow-update-$timestamp"
$backupRoot=Join-Path $RepoPath '.trendflow-backups'
$backup=Join-Path $backupRoot $timestamp

Write-Step 'ZIP 압축 해제'
if(Test-Path -LiteralPath $temp){ Remove-Item -LiteralPath $temp -Recurse -Force }
New-Item -ItemType Directory -Path $temp | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $temp -Force
$extractRoot=$temp
if(-not(Test-Path -LiteralPath (Join-Path $extractRoot 'index.html'))){
  foreach($d in Get-ChildItem -LiteralPath $temp -Directory){ if((Test-Path (Join-Path $d.FullName 'index.html')) -and (Test-Path (Join-Path $d.FullName 'styles.css'))){ $extractRoot=$d.FullName; break } }
}
if(-not(Test-Path -LiteralPath (Join-Path $extractRoot 'index.html'))){ Fail '업데이트 ZIP 안에서 index.html을 찾지 못했습니다.' }
if(-not(Test-Path -LiteralPath (Join-Path $extractRoot 'styles.css'))){ Fail '업데이트 ZIP 안에서 styles.css를 찾지 못했습니다.' }
if(-not(Test-Path -LiteralPath (Join-Path $extractRoot 'version.txt'))){ Fail '업데이트 ZIP 안에서 version.txt를 찾지 못했습니다.' }
$newVersion=Get-VersionFrom $extractRoot
Write-Host "업데이트 버전: $newVersion" -ForegroundColor Yellow

Write-Step 'ZIP 내부 이미지 참조 검사'
$missingBefore=Test-ImageReferences $extractRoot
if($missingBefore.Count -gt 0){ $missingBefore | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }; Fail 'ZIP 내부 이미지 참조 검사 실패' }
Write-Host '이미지 참조 정상' -ForegroundColor Green
if($DryRun){ Write-Step 'DryRun 완료: 실제 복사/커밋/푸시는 하지 않았습니다.'; Remove-Item -LiteralPath $temp -Recurse -Force; exit 0 }

Write-Step '현재 사이트 백업'
New-Item -ItemType Directory -Path $backup | Out-Null
$targets=@('index.html','styles.css','search.html','editor.html','editor-guide.html','version.txt','categories','posts','assets','content')
foreach($item in $targets){ $srcItem=Join-Path $RepoPath $item; if(Test-Path -LiteralPath $srcItem){ Copy-Item -LiteralPath $srcItem -Destination $backup -Recurse -Force } }
Write-Host "백업 완료: $backup" -ForegroundColor Green

Write-Step '기존 사이트 파일 정리'
foreach($item in $targets){ $target=Join-Path $RepoPath $item; if(Test-Path -LiteralPath $target){ Remove-Item -LiteralPath $target -Recurse -Force } }

Write-Step '새 버전 복사'
Copy-DirectoryContents -Source $extractRoot -Destination $RepoPath

Write-Step '복사 후 검증'
$missingAfter=Test-ImageReferences $RepoPath
if($missingAfter.Count -gt 0){ $missingAfter | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }; Fail "복사 후 검증 실패. 백업: $backup" }
Write-Host "로컬 반영 버전: $(Get-VersionFrom $RepoPath)" -ForegroundColor Yellow

Write-Step 'Git add / commit / push'
Push-Location $RepoPath
try{
  git add -A
  $status=git status --porcelain
  if([string]::IsNullOrWhiteSpace($status)){ Write-Host '커밋할 변경사항이 없습니다.' -ForegroundColor Yellow }
  else{
    if([string]::IsNullOrWhiteSpace($CommitMessage)){ $CommitMessage="Update TrendFlow $newVersion" }
    git commit -m $CommitMessage
    if($NoPush){ Write-Host 'NoPush 모드: push는 건너뜁니다.' -ForegroundColor Yellow } else { git push }
  }
}
finally{ Pop-Location; if(Test-Path -LiteralPath $temp){ Remove-Item -LiteralPath $temp -Recurse -Force } }
Write-Step '배포 자동화 완료'
Write-Host '확인 URL: https://trend.it.kr/version.txt' -ForegroundColor Green
Write-Host '브라우저에서 Ctrl+F5로 강력 새로고침하세요.' -ForegroundColor Green
