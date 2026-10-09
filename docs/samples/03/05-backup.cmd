@echo off
rem ============================================================
rem  05-backup.cmd  第3回 最終版
rem   第1回で作ったバックアップスクリプトを配布可能な形にしたもの
rem
rem  使い方: 05-backup.cmd [-v] 対象ファイル
rem
rem  このファイルは SJIS(CP932) + CRLF で保存すること
rem ============================================================

rem --- カレントをこのファイルの場所に固定する ---
pushd "%~dp0" || exit /b 1

rem --- 変数の変更をこのスクリプト内に閉じ、遅延展開を有効にする ---
setlocal enabledelayedexpansion

set "RC=0"

rem --- 引数チェック ---
if "%~1"=="" goto :usage
if "%~1"=="/?" goto :usage
if /i "%~1"=="-h" goto :usage

set "VERBOSE="
if /i "%~1"=="-v" (
	set "VERBOSE=1"
	shift
)

set "SRC=%~1"
if not defined SRC goto :usage

rem --- 日時を確実に取得する（地域設定に依存しない） ---
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "STAMP=%%d"

rem --- ログの準備 ---
set "LOGDIR=%~dp0log"
set "LOGFILE=!LOGDIR!\backup_!STAMP:~0,8!.log"
if not exist "!LOGDIR!" md "!LOGDIR!"

set "DSTDIR=%~dp0backup"

call :log "==== 開始: !SRC! ===="

rem --- 事前確認 ---
if not exist "!SRC!" (
	call :log "[エラー] コピー元が見つかりません: !SRC!"
	set "RC=1"
	goto :finish
)

if not exist "!DSTDIR!\" (
	md "!DSTDIR!" || (
		call :log "[エラー] 保存先を作成できません: !DSTDIR!"
		set "RC=1"
		goto :finish
	)
)

rem --- 本処理 ---
set "DST=!DSTDIR!\!STAMP!_%~nx1"
if defined VERBOSE call :log "コピー先: !DST!"

copy "!SRC!" "!DST!" >nul || (
	call :log "[エラー] コピーに失敗しました"
	set "RC=1"
	goto :finish
)

call :log "完了: !DST!"

:finish
rem --- 後始末。成功・失敗にかかわらずここを通る ---
if "!RC!"=="0" (
	call :log "==== 正常終了 ===="
) else (
	call :log "==== 異常終了 終了コード=!RC! ===="
)
endlocal & set "RC=%RC%"
popd
exit /b %RC%


rem ============================================================
rem  :usage  使い方の表示
rem ============================================================
:usage
echo 使い方: %~nx0 [-v] ^<バックアップするファイル^>
echo.
echo   ^<ファイル^>   バックアップ対象
echo   -v           詳細を表示する
echo.
echo 保存先: このバッチと同じ場所の backup フォルダ
echo ログ  : このバッチと同じ場所の log フォルダ
endlocal
popd
exit /b 1


rem ============================================================
rem  :log  画面とログの両方へ出力する
rem ============================================================
:log
echo %~1
echo [%DATE% %TIME%] %~1 >> "!LOGFILE!"
goto :eof
