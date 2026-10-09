@echo off
rem ============================================================
rem  02-errorhandling.cmd  第3回
rem   エラー処理の型
rem ============================================================
setlocal enabledelayedexpansion
pushd "%~dp0" || exit /b 1

echo === 1. 失敗しても次の行は実行される（例外がない） ===
copy "notexist_xyz.txt" "dummy.txt" >nul 2>&1
echo   copy は失敗したが、この行は実行されている（errorlevel=!errorlevel!）

echo.
echo === 2. 失敗したら止める基本形 ===
copy "notexist_xyz.txt" "dummy.txt" >nul 2>&1 || (
	echo   [エラー] コピーに失敗しました  ... ここで exit /b するのが基本形
)

echo.
echo === 3. 事前確認で弾く ===
if not exist "notexist_xyz.txt" (
	echo   [エラー] 対象が見つかりません: notexist_xyz.txt
	echo   実行して失敗させるより、先に確認したほうがメッセージが分かりやすい
)

echo.
echo === 4. md は既存フォルダでエラーになる ===
md "testdir" 2>nul
echo   1回目: errorlevel=!errorlevel!
md "testdir" 2>nul
echo   2回目: errorlevel=!errorlevel!  ... 既存なので失敗する
echo   失敗しても構わない場合は 2^>nul でエラー出力だけ捨てて続行する

echo.
echo === 5. robocopy は 1?7 も成功 ===
md "robosrc" 2>nul
echo test > "robosrc\a.txt"
robocopy "robosrc" "robodst" /e /r:0 /w:0 >nul 2>&1
set "RC=!errorlevel!"
echo   robocopy の終了コード = !RC!
if !RC! GEQ 8 (
	echo   [エラー] robocopy が失敗しました
) else (
	echo   成功（8 未満は成功扱い）。^|^| で判定すると誤検知する
)

echo.
echo === 6. 後始末を確実に通す ===
echo   :finish ラベルに goto で合流させると、成功・失敗の両方で通せる
goto :finish

:finish
echo   後始末を実行中...
if exist "robosrc\a.txt" del "robosrc\a.txt"
if exist "robodst\a.txt" del "robodst\a.txt"
if exist "robosrc" rd "robosrc"
if exist "robodst" rd "robodst"
if exist "testdir" rd "testdir"
echo   後始末が完了しました
popd
pause
exit /b 0