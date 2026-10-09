@echo off
rem ============================================================
rem  02-expand.cmd  第1回
rem   「バッチは置換してから実行する」ことの確認
rem ============================================================
setlocal enabledelayedexpansion

echo === 1. 未定義の変数は空にならない ===
echo [%UNDEFINED_VAR%]
echo   置換できないので %%UNDEFINED_VAR%% がそのまま残る

echo.
echo === 2. set の書き方の違い ===
set NAME1=太郎
set "NAME2=太郎"
set NAME3 = 太郎
echo NAME1=[%NAME1%]
echo NAME2=[%NAME2%]
echo NAME3=[%NAME3%]
echo   NAME3 は変数名が "NAME3 "（末尾に空白）になったため読めない
echo   set で一覧を見ると実際にどう入ったか分かる:
set NAME3

echo.
echo === 3. パーセント記号 ===
echo 進捗: 50%
echo 進捗: 50%%
echo   バッチ内では %%%% と書く必要がある

echo.
echo === 4. 値はすべて文字列 ===
set "N=5"
set "M=3"
echo %N% + %M% は %N%%M%
set /a SUM=N+M
echo set /a を使うと %SUM%

echo.
echo === 5. 置換した結果はもう一度コマンドとして読み直される ===
set "MSG=Hello & World"
echo   set "名前=値" なので代入自体は成功している。読み出し方で結果が変わる:
echo A: %MSG%
echo B: !MSG!
echo C: "%MSG%"
echo.
echo   A: echo %%MSG%% が echo Hello ^& World という行に化け、
echo      ^& 以降が別のコマンドとして実行されるため壊れる
echo   B: ^^!MSG^^! は実行直前に差し込まれ、結果は読み直されないので正しい
echo   C: 引用符で囲む方法もあるが、引用符自体も表示される

pause