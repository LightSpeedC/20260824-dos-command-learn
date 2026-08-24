@echo off
rem ============================================================
rem  03-errorlevel.cmd  第1回
rem   終了コード（ERRORLEVEL）の確認
rem ============================================================
setlocal

echo === 1. 成功するコマンド ===
dir "%~dp0" >nul
echo errorlevel=%errorlevel%

echo.
echo === 2. 失敗するコマンド ===
dir "Z:\notexist_folder_xyz" >nul 2>&1
echo errorlevel=%errorlevel%

echo.
echo === 3. ^&^& と ^|^| ===
echo 成功したときだけ実行:
dir "%~dp0" >nul && echo   -^> 成功しました
echo 失敗したときだけ実行:
dir "Z:\notexist_folder_xyz" >nul 2>&1 || echo   -^> 失敗しました

echo.
echo === 4. if errorlevel は「その値以上」 ===
call :ret 3
rem 判定に使う前に値を保存する（echo を実行すると errorlevel が上書きされる）
set "RC=%errorlevel%"
echo 終了コード=%RC%
if %RC% GEQ 1 echo   if errorlevel 1 相当は真（3 は 1 以上）
if %RC% GEQ 5 (echo   これは表示されない) else (echo   if errorlevel 5 相当は偽（3 は 5 未満）)

pause
goto :eof

rem 指定された値を終了コードとして返すサブルーチン
:ret
exit /b %1
