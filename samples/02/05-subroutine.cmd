@echo off
rem ============================================================
rem  05-subroutine.cmd  第2回
rem   サブルーチンと戻り値の2つの方法
rem ============================================================
setlocal enabledelayedexpansion

call :log "処理を開始します"

echo.
echo === 方法1: 終了コードで返す（真偽値） ===
call :is_text "sample.txt"
if errorlevel 1 (echo   sample.txt はテキストではない) else (echo   sample.txt はテキストです)
call :is_text "sample.log"
if errorlevel 1 (echo   sample.log はテキストではない) else (echo   sample.log はテキストです)

echo.
echo === 方法2: 変数に書き込んで返す ===
call :get_ext "report.xlsx"
echo   拡張子は !RESULT! です
call :get_ext "archive.tar.gz"
echo   拡張子は !RESULT! です

echo.
echo === サブルーチンは複数回呼べる ===
for %%w in (alpha beta gamma) do call :log "処理中: %%w"

call :log "処理が完了しました"

rem ---- メイン処理の終わり。この goto :eof を忘れると下のラベルへ流れ込む ----
pause
goto :eof


rem ============================================================
rem  :log  日時付きでメッセージを表示する
rem ============================================================
:log
echo [%TIME%] %~1
goto :eof


rem ============================================================
rem  :is_text  拡張子が .txt なら 0、それ以外は 1 を返す
rem   注意: 0 が成功（真）という向きになる
rem ============================================================
:is_text
if /i "%~x1"==".txt" exit /b 0
exit /b 1


rem ============================================================
rem  :get_ext  拡張子を RESULT に入れて返す
rem   バッチにはスコープがないので呼び出し元からも見える
rem ============================================================
:get_ext
set "RESULT=%~x1"
goto :eof
