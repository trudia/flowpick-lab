# TrendFlow V48 다운로드 폴더 감시 자동 배포

V48은 사용자가 요청한 **2번 방법: 다운로드 폴더 감시 방식**을 추가한 버전입니다.

## 핵심 기능

Downloads 폴더에 새 업데이트 ZIP이 저장되면 자동으로 감지합니다.

```text
ChatGPT에서 업데이트 ZIP 다운로드
→ Downloads 폴더에 저장
→ 감시 스크립트가 새 ZIP 감지
→ Y/N 확인
→ 자동 배포
→ Git commit / push
```

## 가장 쉬운 실행

GitHub 저장소 루트에서 아래 파일을 더블클릭하세요.

```text
start-watcher.bat
```

또는:

```text
tools/start-watcher.bat
```

실행 후 창을 켜두면 됩니다.

## 테스트 모드

push 없이 테스트하고 싶으면:

```text
tools/start-watcher-nopush.bat
```

## 윈도우 시작 시 자동 실행 등록

한 번만 실행하세요.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install-watcher-task.ps1
```

등록 후 다음 로그인부터 감시가 자동 시작됩니다.

지금 바로 시작:

```powershell
Start-ScheduledTask -TaskName "TrendFlow Download Watcher"
```

## 자동 실행 제거

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\remove-watcher-task.ps1
```

## 안전장치

기본값은 자동 배포 전에 확인을 받습니다.

```text
새 업데이트 ZIP 발견
배포할까요? Y/N
```

잘못된 ZIP이 자동 배포되는 것을 막기 위한 안전장치입니다.

## 완전 자동으로 바꾸기

확인 없이 자동 배포하려면 PowerShell에서 직접 실행하세요.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\watch-downloads.ps1 -AutoApprove
```

## 현재 버전

```text
v48-download-watcher-automation-2026-05-23
```

## 배포 후 확인

```text
https://trend.it.kr/version.txt
```
