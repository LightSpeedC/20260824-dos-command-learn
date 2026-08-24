@echo off
rem ============================================================
rem  04-args.cmd  第3回
rem   引数解析とヘルプ表示
rem
rem  使い方: 04-args.cmd [-v] [-o 出力先] 対象パス
rem ============================================================
setlocal enabledelayedexpansion

rem --- ヘルプの要求と引数なしを同じ扱いにする ---
if "%~1"=="" goto :usage
if "%~1"=="/?" goto :usage
if /i "%~1"=="-h" goto :usage
if /i "%~1"=="--help" goto :usage

set "VERBOSE="
set "OUTPUT="
set "TARGET="

rem --- 引数を1つずつ調べる ---
:parse
if "%~1"=="" goto :parse_done
if /i "%~1"=="-v" (
	set "VERBOSE=1"
) else if /i "%~1"=="-o" (
	rem 次の引数を値として取り、余分に1つ進める
	set "OUTPUT=%~2"
	shift
) else (
	set "TARGET=%~1"
)
shift
goto :parse

:parse_done
if not defined TARGET (
	echo [エラー] 対象を指定してください
	echo.
	goto :usage
)

echo === 解析結果 ===
echo   対象     = [!TARGET!]
if defined VERBOSE (echo   詳細表示 = 有効) else (echo   詳細表示 = 無効)
if defined OUTPUT (echo   出力先   = [!OUTPUT!]) else (echo   出力先   = 未指定)

echo.
echo shift の位置を1つ間違えると無限ループになる。
echo オプションが3つ以上になるなら、バッチ以外を検討する合図。
pause
exit /b 0

:usage
echo 使い方: %~nx0 [-v] [-o 出力先] ^<対象パス^>
echo.
echo   ^<対象パス^>   処理するファイルまたはフォルダ
echo   -v           詳細を表示する
echo   -o 出力先    出力先を指定する
echo   -h, --help   このヘルプを表示する
pause
exit /b 1
