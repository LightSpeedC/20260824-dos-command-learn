@echo off
rem ============================================================
rem  01-delayed-ok.cmd  第2回  修正版
rem   遅延展開を使うと実行直前に評価される
rem ============================================================
setlocal enabledelayedexpansion

set "COUNT=0"

echo === カレントのファイルを数える（修正版） ===
for %%f in ("%~dp0*.cmd") do (
	set /a COUNT+=1
	echo 現在: !COUNT!   %%~nxf = %%~nxf
)

echo.
echo 合計: !COUNT! 件

echo.
echo === 遅延展開のもう1つの役割: 再解析を止める ===
set "MSG=Hello & World"
echo B: !MSG!
echo   通常の展開だと ^& がコマンド区切りとして働いて壊れる
echo   （01-delayed-ng.cmd ではなく 02-expand.cmd 第1回 で確認できる）
pause
