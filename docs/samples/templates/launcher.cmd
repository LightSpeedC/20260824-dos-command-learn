@echo off
rem ============================================================
rem  ランチャー型テンプレート
rem   ps1 や exe をダブルクリックで起動するための入口。
rem   このファイルは SJIS(CP932) + CRLF で保存すること。
rem ============================================================

rem --- 起動対象（このファイルと同じフォルダにある想定） ---
set "SCRIPT=main.ps1"

rem --- カレントをこのファイルの場所へ ---
pushd "%~dp0" || exit /b 1

if not exist "%SCRIPT%" (
	echo [エラー] 起動対象が見つかりません: %SCRIPT%
	popd
	pause
	exit /b 1
)

rem --- 実行 ---
rem  -NoProfile              : プロファイルを読まない。起動が速く、環境差も出ない
rem  -ExecutionPolicy Bypass : 実行ポリシーの制約を回避する
rem  %* は、このバッチに渡された引数をそのまま渡すため
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
set "RC=%errorlevel%"

popd

if not "%RC%"=="0" echo [エラー] 終了コード: %RC%

rem --- ダブルクリック実行でも結果が読めるように待つ ---
rem  タスクスケジューラから使う場合はこの pause を消す（入力待ちで止まるため）
pause
exit /b %RC%
