@echo off
rem ============================================================
rem  バッチ処理型テンプレート
rem   タスクスケジューラ等からの無人実行を想定。ログを残す。
rem   このファイルは SJIS(CP932) + CRLF で保存すること。
rem ============================================================

pushd "%~dp0" || exit /b 1
setlocal enabledelayedexpansion

rem --- 日付を yyyymmdd 形式で取得する ---
rem  %DATE% の書式はロケール設定に依存するため、PowerShell で確実に整形する
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"`) do set "TODAY=%%d"

rem --- ログの準備 ---
set "LOGDIR=%~dp0log"
set "LOGFILE=!LOGDIR!\job_!TODAY!.log"
if not exist "!LOGDIR!" md "!LOGDIR!"

call :log "==== 処理を開始します ===="

rem --- 本処理。標準出力と標準エラーをまとめてログへ回す ---
call :main >> "!LOGFILE!" 2>&1
set "RC=!errorlevel!"

if "!RC!"=="0" (
	call :log "==== 正常終了しました ===="
) else (
	call :log "==== 異常終了しました 終了コード=!RC! ===="
)

endlocal & set "RC=%RC%"
popd
exit /b %RC%


rem ============================================================
rem  :main  本処理（出力はすべてログファイルへ）
rem ============================================================
:main
echo 本処理を実行中...

rem ここに処理を書く
rem 例) robocopy は 8 以上が失敗（1?7 は成功扱い）
rem   robocopy "src" "dst" /e /r:1 /w:1
rem   if errorlevel 8 exit /b 1

exit /b 0


rem ============================================================
rem  :log  日時付きで画面とログの両方に出力する
rem ============================================================
:log
echo [%DATE% %TIME%] %~1
echo [%DATE% %TIME%] %~1 >> "!LOGFILE!"
goto :eof
