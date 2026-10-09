@echo off
rem ============================================================
rem  02-if.cmd  第2回
rem   if の4つの形と数値比較
rem ============================================================
setlocal enabledelayedexpansion

echo === 1. 文字列比較 ===
set "MODE=test"
if "%MODE%"=="test" echo   MODE は test です
if /i "%MODE%"=="TEST" echo   /i を付けると大文字小文字を区別しない
if not "%MODE%"=="prod" echo   not で否定できる

echo.
echo === 2. 両辺を引用符で囲む理由 ===
set "EMPTY="
echo   EMPTY は未定義。引用符があれば構文が壊れない:
if "%EMPTY%"=="x" (echo   一致) else (echo   不一致と正しく判定された)

echo.
echo === 3. 存在確認 ===
if exist "%~dp0" echo   このフォルダは存在します
if not exist "%~dp0notexist_xyz.txt" echo   notexist_xyz.txt はありません
echo   フォルダを確かめたいときは末尾にバックスラッシュを付ける

echo.
echo === 4. 変数の定義 ===
if defined MODE echo   MODE は定義されています（パーセントで囲まない）
if not defined UNDEFINED_XYZ echo   UNDEFINED_XYZ は未定義です

echo.
echo === 5. 数値比較 ===
set "N=7"
if %N% GEQ 5 echo   %N% は 5 以上（GEQ）
if %N% LSS 10 echo   %N% は 10 未満（LSS）
echo   == は文字列比較なので "05" と "5" は不一致になる:
if "05"=="5" (echo   一致) else (echo   不一致)
set /a A=05
set /a B=5
if %A% EQU %B% echo   set /a を通せば EQU で一致する

echo.
echo === 6. else は同じ行に置く ===
if "%MODE%"=="test" (
	echo   テストモード
) else (
	echo   本番モード
)
echo   閉じ括弧と else と開き括弧を別の行に分けると構文エラーになる
pause
