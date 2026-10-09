@echo off
rem ============================================================
rem  03-logging.cmd  第3回
rem   ログ出力とリダイレクトの順序
rem ============================================================
setlocal enabledelayedexpansion
pushd "%~dp0" || exit /b 1

rem --- 日付を確実に取得する ---
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"`) do set "TODAY=%%d"

set "LOGDIR=%~dp0log"
set "LOGFILE=!LOGDIR!\demo_!TODAY!.log"
if not exist "!LOGDIR!" md "!LOGDIR!"

echo === リダイレクトの順序の違いを確認する ===
echo   正しい形: 先にファイルへ向けてから 2^>^&1 と書く
type "notexist_xyz.txt" >> "!LOGFILE!" 2>&1
echo   -^> エラーはログに入り、画面には何も出ない

echo   誤った形: 2^>^&1 を先に書くとエラーが画面に残る
echo   （この下にエラーメッセージが表示されます）
type "notexist_xyz.txt" 2>&1 >> "!LOGFILE!"

echo.
echo === 画面とログの両方に出す ===
call :log "==== 処理を開始します ===="

echo.
echo === サブルーチン全体の出力をログへ回す ===
call :main >> "!LOGFILE!" 2>&1
set "RC=!errorlevel!"
echo   :main の出力はすべてログへ入った（画面には出ていない）

if "!RC!"=="0" (
	call :log "==== 正常終了しました ===="
) else (
	call :log "==== 異常終了しました 終了コード=!RC! ===="
)

echo.
echo === 生成されたログ ===
echo   !LOGFILE!
type "!LOGFILE!"

popd
pause
exit /b 0


rem ============================================================
rem  :main  本処理（出力はすべてログへ）
rem ============================================================
:main
echo 本処理を実行中...
echo この行もログにだけ入る
exit /b 0


rem ============================================================
rem  :log  画面とログの両方へ出力する
rem ============================================================
:log
echo [%DATE% %TIME%] %~1
echo [%DATE% %TIME%] %~1 >> "!LOGFILE!"
goto :eof
