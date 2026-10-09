@echo off
rem ============================================================
rem  06-sort.cmd  第2回 デモの完成版（Step 3）
rem   フォルダ内のファイルを拡張子ごとに振り分けてコピーする
rem
rem  使い方: 06-sort.cmd "対象フォルダ"
rem          省略すると testfiles フォルダを対象にする
rem ============================================================
setlocal enabledelayedexpansion

set "SRCDIR=%~1"
if "%SRCDIR%"=="" set "SRCDIR=%~dp0testfiles"

if not exist "%SRCDIR%\" (
	echo [エラー] フォルダが見つかりません: %SRCDIR%
	pause
	exit /b 1
)

rem 保存先はこのバッチと同じ場所の sorted フォルダ
set "DSTBASE=%~dp0sorted"
set "TOTAL=0"
set "FAILED=0"

echo 対象: %SRCDIR%
echo 保存先: %DSTBASE%
echo.

for %%f in ("%SRCDIR%\*") do (
	rem 拡張子から保存先フォルダ名を作る（.txt から txt へ）
	rem 空のまま置換記法を使うと予期しない値になるため、先に空を判定する
	set "EXT=%%~xf"
	if "!EXT!"=="" (
		set "EXT=noext"
	) else (
		set "EXT=!EXT:.=!"
	)

	set "DSTDIR=%DSTBASE%\!EXT!"
	if not exist "!DSTDIR!\" md "!DSTDIR!"

	copy "%%~ff" "!DSTDIR!\" >nul && (
		set /a TOTAL+=1
		echo   OK   %%~nxf -^> !EXT!\
	) || (
		set /a FAILED+=1
		echo   NG   %%~nxf
	)
)

echo.
echo コピー成功: !TOTAL! 件 / 失敗: !FAILED! 件
pause
if !FAILED! GTR 0 exit /b 1
exit /b 0
