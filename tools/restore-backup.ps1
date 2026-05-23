param([Parameter(Mandatory=$true)][string]$BackupFolder,[string]$RepoPath=(Resolve-Path ".").Path)
$ErrorActionPreference='Stop'
$BackupFolder=[System.IO.Path]::GetFullPath($BackupFolder)
$RepoPath=[System.IO.Path]::GetFullPath($RepoPath)
if(-not(Test-Path -LiteralPath $BackupFolder)){ Write-Host "백업 폴더를 찾을 수 없습니다: $BackupFolder" -ForegroundColor Red; exit 1 }
$targets=@('index.html','styles.css','search.html','editor.html','editor-guide.html','version.txt','categories','posts','assets','content')
foreach($item in $targets){ $target=Join-Path $RepoPath $item; if(Test-Path -LiteralPath $target){ Remove-Item -LiteralPath $target -Recurse -Force } }
Get-ChildItem -LiteralPath $BackupFolder -Force | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $RepoPath $_.Name) -Recurse -Force }
Write-Host "복구 완료: $BackupFolder" -ForegroundColor Green
Write-Host '필요하면 git add -A / git commit / git push를 실행하세요.' -ForegroundColor Yellow
