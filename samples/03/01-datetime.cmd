@echo off
rem ============================================================
rem  01-datetime.cmd  第3回
rem   日時を取得する3つの方法を並べて比較する
rem ============================================================
setlocal enabledelayedexpansion

echo === 生の値（そのまま使うと壊れる） ===
echo   DATE = [%DATE%]
echo   TIME = [%TIME%]
echo   TIME は時が1桁だと先頭が空白になる。コロンとピリオドはファイル名に使えない

echo.
echo === 方法1: PowerShell を呼ぶ（推奨） ===
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "STAMP1=%%d"
echo   結果 = [!STAMP1!]
echo   書式を明示するので地域設定に依存しない。起動に数百ミリ秒かかる

echo.
echo === 方法2: wmic を使う（非推奨） ===
for /f "tokens=2 delims==" %%d in ('wmic os get localdatetime /value 2^>nul ^| find "="') do set "LDT=%%d"
echo   生の値 = [!LDT!]
echo   末尾に余分な文字が混入するため、部分取得で必要な桁だけ切り出す
set "STAMP2=!LDT:~0,8!_!LDT:~8,6!"
echo   結果   = [!STAMP2!]
echo   wmic は非推奨。将来の Windows で削除される予定

echo.
echo === 方法3: DATE と TIME を加工（地域依存） ===
set "D=%DATE:/=%"
rem 先頭の空白を 0 に置換してから、コロンとピリオドを削除する
set "T=%TIME: =0%"
set "T=!T::=!"
set "T=!T:.=!"
set "STAMP3=!D!_!T:~0,6!"
echo   結果 = [!STAMP3!]
echo   外部プロセスを起動しないので高速。ただし地域設定に依存する

echo.
echo === 結論 ===
echo   配布するバッチ         -^> 方法1
echo   自分専用の使い捨て     -^> 方法3
echo   既存コードの保守のみ   -^> 方法2
pause
