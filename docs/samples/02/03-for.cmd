@echo off
rem ============================================================
rem  03-for.cmd  第2回
rem   for の4つの形
rem ============================================================
setlocal enabledelayedexpansion

pushd "%~dp0" || exit /b 1

echo === 1. 無印: ファイル名を回す ===
for %%f in (*.cmd) do echo   %%~nxf

echo.
echo === 2. 無印: 空白区切りの単語を回す（配列の代用） ===
for %%w in (alpha beta gamma) do echo   [%%w]

echo.
echo === 3. /l: 回数ループ ===
for /l %%i in (1,1,5) do echo   %%i
echo   逆順（増分を負にする）:
for /l %%i in (3,-1,1) do echo   %%i

echo.
echo === 4. /f: ファイルの各行を読む ===
echo   --- 引用符なし: ファイルの中身を読む ---
for /f "delims=" %%l in (data.txt) do echo   %%l
echo   --- 引用符あり: 文字列そのものになってしまう ---
for /f "delims=" %%l in ("data.txt") do echo   %%l

echo.
echo === 5. /f: usebackq で空白を含むパスを読む ===
for /f "usebackq delims=" %%l in ("%~dp0data file.txt") do echo   %%l

echo.
echo === 6. /f: tokens と delims でCSVを分解 ===
for /f "skip=1 tokens=1,2,3 delims=," %%a in (list.csv) do (
	echo   名前=%%a / 部署=%%b / 年齢=%%c
)

echo.
echo === 7. /f: コマンドの出力を読む ===
for /f "usebackq delims=" %%l in (`dir /b *.csv`) do echo   %%l

echo.
echo === 8. /d: フォルダのみ ===
for /d %%d in (*) do echo   [DIR] %%~nxd

echo.
echo === 9. /r: サブフォルダも含める ===
for /r "%~dp0testfiles" %%f in (*.txt) do echo   %%~nxf

echo.
echo === 10. ループ変数にもチルダ修飾子が使える ===
for %%f in (list.csv) do (
	echo   フルパス = %%~ff
	echo   名前     = %%~nf
	echo   拡張子   = %%~xf
	echo   サイズ   = %%~zf
)

echo.
echo === 11. break はない。goto で抜ける ===
for /l %%i in (1,1,10) do (
	echo   %%i
	if %%i GEQ 3 goto :out
)
:out
echo   3 で抜けました

popd
pause
