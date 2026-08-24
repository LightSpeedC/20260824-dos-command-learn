@echo off
rem ============================================================
rem  ツール型テンプレート
rem   引数を受け取って処理を行うバッチ。手で実行する用途を想定。
rem   このファイルは SJIS(CP932) + CRLF で保存すること。
rem ============================================================

rem --- カレントディレクトリをこのファイルの場所に固定する ---
rem  ダブルクリックや別フォルダからの呼び出しでもパスがずれないようにする
rem  cd ではなく pushd を使う理由: 共有フォルダ(UNCパス)でも動くため
pushd "%~dp0" || exit /b 1

rem --- 変数の変更をこのスクリプト内に閉じ、!VAR! を有効にする ---
setlocal enabledelayedexpansion

rem --- 引数チェック ---
if "%~1"=="" goto :usage
if /i "%~1"=="/?" goto :usage
if /i "%~1"=="-h" goto :usage

rem  %~1 で引用符を外して受け取り、使うときに改めて "" で囲む
set "TARGET=%~1"
set "OPTION=%~2"

if not exist "!TARGET!" (
	echo [エラー] 対象が見つかりません: !TARGET!
	set "RC=1"
	goto :finish
)

rem --- 本処理 ---
call :main
set "RC=!errorlevel!"

if "!RC!"=="0" (
	echo 完了しました。
) else (
	echo [エラー] 処理に失敗しました。終了コード: !RC!
)

:finish
rem --- 後始末。RC を endlocal の外へ持ち出してから戻る ---
endlocal & set "RC=%RC%"
popd
exit /b %RC%


rem ============================================================
rem  :main  本処理
rem   失敗したら exit /b で 0 以外を返す
rem ============================================================
:main
echo 対象: !TARGET!
if not "!OPTION!"=="" echo オプション: !OPTION!

rem ここに処理を書く
rem 例) 失敗したら中断する
rem   copy "!TARGET!" "backup\" >nul || exit /b 1

exit /b 0


rem ============================================================
rem  :usage  使い方の表示
rem ============================================================
:usage
echo 使い方: %~nx0 ^<対象パス^> [オプション]
echo.
echo   対象パス    処理するファイルまたはフォルダ
echo   オプション  省略可
popd
exit /b 1
