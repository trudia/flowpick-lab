# TrendFlow V46 배포 자동화 안내

이 버전은 사이트 파일에 `tools/` 자동 배포 도구를 포함한 버전입니다.

## 목표

앞으로 ChatGPT가 만들어주는 업데이트 ZIP을 수동으로 일일이 옮기지 않고 아래 흐름으로 배포합니다.

1. 업데이트 ZIP 다운로드
2. GitHub 저장소 루트에서 `tools/deploy-update.bat` 실행
3. ZIP 경로 붙여넣기
4. 자동 백업
5. 자동 압축 해제
6. 이미지 참조 검사
7. Git add / commit / push
8. GitHub Pages 반영 확인

## 처음 한 번만 필요한 준비

- PC에 Git 설치
- GitHub 저장소가 PC에 clone 되어 있음
- GitHub 로그인 또는 인증 설정 완료
- 이 V46 ZIP의 모든 파일을 GitHub 저장소 루트에 반영

## 가장 쉬운 실행 방법

GitHub 저장소 루트에서 아래 파일을 더블클릭하세요.

```text
deploy-update.bat
```

또는:

```text
tools\deploy-update.bat
```

## PowerShell 직접 실행

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\deploy-update.ps1 -ZipPath "C:\Users\사용자\Downloads\업데이트파일.zip"
```

## 푸시 없이 테스트

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\deploy-update.ps1 -ZipPath "C:\Users\사용자\Downloads\업데이트파일.zip" -NoPush
```

## ZIP 검증만 하기

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\deploy-update.ps1 -ZipPath "C:\Users\사용자\Downloads\업데이트파일.zip" -DryRun
```

## 로컬 검증

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify-site.ps1
```

## 백업 위치

```text
.trendflow-backups/YYYYMMDD-HHMMSS
```

## 복구

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\restore-backup.ps1 -BackupFolder ".\.trendflow-backups\백업폴더명"
```

## 현재 자동화 버전

```text
v46-deploy-automation-ready-2026-05-23
```

## 배포 후 확인

```text
https://trend.it.kr/version.txt
```
