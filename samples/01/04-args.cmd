@echo off
rem ============================================================
rem  04-args.cmd  第1回
rem   引数とチルダ修飾子の確認
rem
rem  使い方: 04-args.cmd "sample.txt" abc
rem ============================================================
setlocal

if "%~1"=="" (
	echo 使い方: %~nx0 ^<ファイルパス^> [追加の引数...]
	echo.
	echo 例: %~nx0 "%~dp0sample.txt" abc
	pause
	exit /b 1
)

echo === 引数そのもの ===
echo %%0   = %0
echo %%1   = %1
echo %%~1  = %~1
echo %%*   = %*

echo.
echo === チルダ修飾子（%%1 に対して） ===
echo %%~f1  フルパス       = %~f1
echo %%~d1  ドライブ       = %~d1
echo %%~p1  パス           = %~p1
echo %%~dp1 ドライブ+パス  = %~dp1
echo %%~n1  名前           = %~n1
echo %%~x1  拡張子         = %~x1
echo %%~nx1 名前+拡張子    = %~nx1

if exist "%~1" (
	echo %%~t1  更新日時       = %~t1
	echo %%~z1  サイズ         = %~z1
)

echo.
echo === 自分の場所とカレントは別物 ===
echo %%~dp0 = %~dp0
echo %%CD%%   = %CD%

pause
