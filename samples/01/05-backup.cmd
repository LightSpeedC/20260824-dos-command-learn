@echo off
rem ============================================================
rem  05-backup.cmd  第1回 デモの完成版（Step 5）
rem   指定したファイルを、日付付きの名前で backup フォルダにコピーする
rem
rem  使い方: 05-backup.cmd "コピーしたいファイル"
rem ============================================================
setlocal

rem --- 引数チェック ---
if "%~1"=="" (
	echo 使い方: %~nx0 ^<バックアップするファイル^>
	pause
	exit /b 1
)

set "SRC=%~1"
rem 保存先はこのバッチと同じ場所の backup フォルダ
set "DSTDIR=%~dp0backup"

rem %DATE% は 2026/08/25 形式。/ を削除して 20260825 にする
rem （この方法は地域設定に依存する。確実な方法は第3回で扱う）
set "TODAY=%DATE:/=%"

if not exist "%SRC%" (
	echo [エラー] コピー元が見つかりません: %SRC%
	pause
	exit /b 1
)

if not exist "%DSTDIR%\" md "%DSTDIR%"

rem %~nx1 で「ファイル名＋拡張子」を取り出して名前を組み立てる
set "DST=%DSTDIR%\%TODAY%_%~nx1"

copy "%SRC%" "%DST%" >nul || (
	echo [エラー] コピーに失敗しました
	pause
	exit /b 1
)

echo 完了: %DST%
pause
exit /b 0
