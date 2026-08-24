@echo off
rem ============================================================
rem  04-string.cmd  第2回
rem   文字列操作（部分取得・置換・含有判定）
rem ============================================================
setlocal enabledelayedexpansion

set "V=abcdefg"
echo === 部分取得（V=%V%） ===
echo   先頭3文字        = %V:~0,3%
echo   3文字目から末尾  = %V:~3%
echo   末尾2文字        = %V:~-2%
echo   末尾2文字を除く  = %V:~0,-2%

echo.
echo === 置換 ===
echo   abc を X に      = %V:abc=X%
echo   abc を削除       = %V:abc=%

echo.
echo === 含有判定（削除して変化があれば含んでいた） ===
if not "%V:cde=%"=="%V%" (echo   cde を含みます) else (echo   cde を含みません)
if not "%V:xyz=%"=="%V%" (echo   xyz を含みます) else (echo   xyz を含みません)

echo.
echo === 末尾のバックスラッシュを取り除く ===
set "P=C:\work\data\"
echo   処理前 = %P%
if "%P:~-1%"=="\" set "P=%P:~0,-1%"
echo   処理後 = %P%

echo.
echo === 日付を組み立てる（地域設定に依存する） ===
echo   DATE の生の値 = %DATE%
echo   区切りを削除  = %DATE:/=%
echo   年            = %DATE:~0,4%
echo   月            = %DATE:~5,2%
echo   日            = %DATE:~8,2%
echo   この方法は環境依存。確実な方法は第3回で扱う

echo.
echo === ループ内では遅延展開の形で書く ===
for %%w in (alpha beta gamma) do (
	set "W=%%w"
	echo   %%w の先頭2文字 = !W:~0,2!
)
echo   ループ変数に直接は置換記法を使えないため、いったん変数に入れる
pause
