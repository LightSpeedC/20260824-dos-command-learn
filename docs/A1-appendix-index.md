# 付録: 逆引き参照

3つの入口から該当箇所を引く索引。本編が「学ぶ順」、この付録が「探す順」です

> 📅 作成: 2026-08-25 / 更新: 2026-08-25

[← README に戻る](../README.md)

## どの索引を使うか

| 索引 | 手がかり | こんなとき |
| --- | --- | --- |
| [索引A](#ch01)やりたいこと | 日本語の目的 | これから書く。何を使えばいいか分からない |
| [索引B](#ch02)他言語の構文 | 既知言語の書き方 | 書きたい処理は頭にあり、記法だけが分からない |
| [索引C](#ch03)症状 | エラー文・おかしな挙動 | すでに書いたものが動かない |

## 参照先の略号

| 略号 | 資料 |
| --- | --- |
| 第1回 | [バッチの実行モデル](01-execution-model.md) |
| 第2回 | [制御構文と展開の罠](02-control-flow.md) |
| 第3回 | [実務で使えるバッチを書く](03-practical.md) |
| 早見表 | [記法早見表](A2-cheatsheet.md) |
| 落とし穴 | [落とし穴カタログ](A3-pitfalls.md) |

1. [索引A: やりたいこと逆引き](#ch01)
2. [索引B: 他言語からの逆引き](#ch02)
3. [索引C: 症状からの逆引き](#ch03)

<a id="ch01"></a>

## 1. 索引A: やりたいこと逆引き

### ファイルとフォルダ

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| フォルダ内のファイルを1つずつ処理する | `for %%f in (*) do` | [第2回 3章](02-control-flow.md#ch03) |
| サブフォルダも含めて処理する | `for /r` | [第2回 3章](02-control-flow.md#ch03) |
| フォルダだけを処理する | `for /d` | [第2回 3章](02-control-flow.md#ch03) |
| ファイル・フォルダの存在を確認する | `if exist "path"` | [第2回 2章](02-control-flow.md#ch02) |
| フォルダを作る（あってもエラーにしない） | `md "path" 2>nul` | [第3回 5章](03-practical.md#ch05) |
| ファイル名・拡張子・フォルダを分解する | `%~n1` `%~x1` `%~dp1` | [第1回 5章](01-execution-model.md#ch05) |
| 大量ファイルを差分コピーする | `robocopy` | [第3回 5章](03-practical.md#ch05) |
| 共有フォルダ（UNC パス）を扱う | `pushd` / `popd` | [第3回 4章](03-practical.md#ch04) |

### テキストの読み書き

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| テキストファイルを1行ずつ読む | `for /f "delims=" %%l in (a.txt)` | [第2回 3章](02-control-flow.md#ch03) |
| 空白を含むパスのファイルを読む | `usebackq` | [第2回 3章](02-control-flow.md#ch03) |
| CSV を列に分解する | `tokens` / `delims` | [第2回 3章](02-control-flow.md#ch03) |
| ヘッダ行を読み飛ばす | `skip=1` | [第2回 3章](02-control-flow.md#ch03) |
| コマンドの出力を1行ずつ処理する | `for /f … in ('cmd')` | [第2回 3章](02-control-flow.md#ch03) |
| ファイルに書き出す | `echo … > file` / `>>` | [早見表 7章](A2-cheatsheet.md#ch07) |
| 文字列を検索する | `findstr` | [早見表 8章](A2-cheatsheet.md#ch08) |
| 出力を捨てる | `>nul` / `2>nul` | [早見表 7章](A2-cheatsheet.md#ch07) |

### 変数と値の加工

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 変数に値を入れる（安全な形） | `set "V=値"` | [第1回 3章](01-execution-model.md#ch03) |
| 数を数える・計算する | `set /a` | [第1回 3章](01-execution-model.md#ch03) |
| ループの中でカウントする | `!VAR!`（遅延展開） | [第2回 4章](02-control-flow.md#ch04) |
| 記号（`&` `\|`）を含む値を扱う | `!VAR!` で読む | [第2回 4章](02-control-flow.md#ch04) |
| 文字列の一部を取り出す | `%V:~0,3%` | [第2回 5章](02-control-flow.md#ch05) |
| 文字列を置換・削除する | `%V:a=b%` / `%V:a=%` | [第2回 5章](02-control-flow.md#ch05) |
| 文字列を含むか判定する | `if not "%V:x=%"=="%V%"` | [第2回 5章](02-control-flow.md#ch05) |
| 環境変数を汚さない | `setlocal` | [第1回 3章](01-execution-model.md#ch03) |
| 呼び出し元に値を1つ返す | `endlocal & set "V=%V%"` | [第3回 5章](03-practical.md#ch05) |

### 制御と構造

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 条件で分岐する | `if "%A%"=="x" ( … ) else ( … )` | [第2回 2章](02-control-flow.md#ch02) |
| 数値を比較する | `GEQ` `LSS` 等 | [第2回 2章](02-control-flow.md#ch02) |
| 3つ以上に分岐する | `goto` でラベルへ | [第2回 2章](02-control-flow.md#ch02) |
| 回数を指定して繰り返す | `for /l` | [第2回 3章](02-control-flow.md#ch03) |
| ループを抜ける（`break` の代用） | `goto` | [第2回 3章](02-control-flow.md#ch03) |
| 処理を関数のようにまとめる | `call :label` / `goto :eof` | [第2回 6章](02-control-flow.md#ch06) |
| 真偽値を返す | `exit /b 0` / `exit /b 1` | [第2回 6章](02-control-flow.md#ch06) |
| 別のバッチを呼んで戻る | `call other.cmd` | [第2回 6章](02-control-flow.md#ch06) |
| ps1 や exe を起動する | `powershell -File` / `start ""` | [第3回 8章](03-practical.md#ch08) |

### エラー処理と終了コード

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 失敗したらそこで止める | `コマンド \|\| exit /b 1` | [第3回 5章](03-practical.md#ch05) |
| 成功したときだけ次に進む | `コマンド && 次` | [第1回 4章](01-execution-model.md#ch04) |
| ブロックの中で終了コードを見る | `if errorlevel 1` / `!errorlevel!` | [第2回 4章](02-control-flow.md#ch04) |
| `robocopy` の成否を判定する | `if errorlevel 8` | [第3回 5章](03-practical.md#ch05) |
| 成功・失敗の両方で後始末を通す | `goto :finish` で合流 | [第3回 5章](03-practical.md#ch05) |
| 自分の終了コードを返す | `exit /b n` | [第1回 4章](01-execution-model.md#ch04) |

### 引数と実行環境

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 引数を受け取る | `%~1` | [第1回 5章](01-execution-model.md#ch05) |
| 引数がないときヘルプを出す | `if "%~1"=="" goto :usage` | [第3回 7章](03-practical.md#ch07) |
| オプション（`-v` 等）を解析する | `shift` ループ | [第3回 7章](03-practical.md#ch07) |
| スクリプトと同じ場所のファイルを参照する | `"%~dp0file"` | [第3回 4章](03-practical.md#ch04) |
| カレントディレクトリを固定する | `pushd "%~dp0"` | [第3回 4章](03-practical.md#ch04) |
| 管理者権限があるか確認する | `net session >nul 2>&1` | [第3回 4章](03-practical.md#ch04) |
| ダブルクリックでも結果を読ませる | `pause` | [第3回 4章](03-practical.md#ch04) |

### 日時・ログ・文字コード

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 日付入りのファイル名を作る（確実な方法） | PowerShell の `Get-Date` を呼ぶ | [第3回 3章](03-practical.md#ch03) |
| 日時を高速に取得する（自分専用） | `%DATE:/=%` / `%TIME: =0%` | [第3回 3章](03-practical.md#ch03) |
| 画面の出力をログに残す | `>> log.txt 2>&1` | [第3回 6章](03-practical.md#ch06) |
| 画面とログの両方に出す | `:log` サブルーチンで2回 `echo` | [第3回 6章](03-practical.md#ch06) |
| 日付ごとにログを分ける | `log\job_%TODAY%.log` | [第3回 6章](03-practical.md#ch06) |
| 日本語を正しく表示する | SJIS + CRLF で保存する | [第3回 2章](03-practical.md#ch02) |
| コードページに依存しないようにする | メッセージを英数字だけにする | [第3回 2章](03-practical.md#ch02) |

### 書き始める・デバッグする

| やりたいこと | 使うもの | 参照先 |
| --- | --- | --- |
| 新しくバッチを書き始める | `templates\tool.cmd` をコピー | [第3回 8章](03-practical.md#ch08) |
| ps1 のランチャーを作る | `templates\launcher.cmd` | [第3回 8章](03-practical.md#ch08) |
| 定時実行のバッチを作る | `templates\batchjob.cmd` | [第3回 8章](03-practical.md#ch08) |
| 動かない原因を調べる | `@echo off` を外す | [第1回 2章](01-execution-model.md#ch02) |
| 変数に何が入っているか確認する | `set VAR`（前方一致で表示） | [第1回 3章](01-execution-model.md#ch03) |
| 配布前に確認する | チェックリスト10項目 | [第3回 8章](03-practical.md#ch08) |
| バッチをやめる判断をする | 限界の4条件 | [第3回 9章](03-practical.md#ch09) |

<a id="ch02"></a>

## 2. 索引B: 他言語からの逆引き

本編の各回にある対比表は「学ぶための対比」で、対比が破綻する点の説明を含みます。この索引は「引くための対比」なので、記法と参照先だけに絞っています。

### 基本構文

| JS | Java / C# | バッチ | 参照先 |
| --- | --- | --- | --- |
| `console.log(x)` | `System.out.println(x)` | `echo %x%` | [第1回 2章](01-execution-model.md#ch02) |
| `let n = 5` | `int n = 5;` | `set "n=5"` | [第1回 3章](01-execution-model.md#ch03) |
| `n + 1` | `n + 1` | `set /a n=n+1` | [第1回 3章](01-execution-model.md#ch03) |
| `// コメント` | `// コメント` | `rem コメント` | [第1回 2章](01-execution-model.md#ch02) |
| `process.env.X` | `System.getenv("X")` | `%X%` | [第1回 3章](01-execution-model.md#ch03) |

### 条件とループ

| JS | Java / C# | バッチ | 参照先 |
| --- | --- | --- | --- |
| `if (a === b)` | `if (a.equals(b))` | `if "%a%"=="%b%"` | [第2回 2章](02-control-flow.md#ch02) |
| `if (n >= 10)` | `if (n >= 10)` | `if %n% GEQ 10` | [第2回 2章](02-control-flow.md#ch02) |
| `if (!x)` | `if (x == null)` | `if not defined x` | [第2回 2章](02-control-flow.md#ch02) |
| `switch` | `switch` | `goto` でラベルへ | [第2回 2章](02-control-flow.md#ch02) |
| `for (const x of arr)` | `for (var x : arr)` | `for %%x in (…) do` | [第2回 3章](02-control-flow.md#ch03) |
| `for (let i=0;i<n;i++)` | 同じ | `for /l %%i in (1,1,n)` | [第2回 3章](02-control-flow.md#ch03) |
| `break` | `break` | `goto :out` | [第2回 3章](02-control-flow.md#ch03) |
| `continue` | `continue` | `if` で処理全体を囲む | [第2回 3章](02-control-flow.md#ch03) |
| `arr[i]` | `arr[i]` | **存在しない** | [第3回 9章](03-practical.md#ch09) |

### 関数とエラー処理

| JS | Java / C# | バッチ | 参照先 |
| --- | --- | --- | --- |
| `function f() {}` | メソッド | `:f` ラベル | [第2回 6章](02-control-flow.md#ch06) |
| `f(a)` | `f(a)` | `call :f "a"` | [第2回 6章](02-control-flow.md#ch06) |
| 仮引数 | 仮引数 | `%~1` | [第2回 6章](02-control-flow.md#ch06) |
| `return` | `return;` | `goto :eof` | [第2回 6章](02-control-flow.md#ch06) |
| `return true` | `return true;` | `exit /b 0`（0 が真） | [第2回 6章](02-control-flow.md#ch06) |
| `throw` | `throw` | `exit /b 1` | [第1回 4章](01-execution-model.md#ch04) |
| `try / catch` | `try / catch` | `\|\| ( … )` | [第3回 5章](03-practical.md#ch05) |
| `finally` | `finally` | `goto :finish` で合流 | [第3回 5章](03-practical.md#ch05) |
| `process.exit(1)` | `System.exit(1)` | `exit /b 1` | [第1回 4章](01-execution-model.md#ch04) |

### 文字列とパス

| JS | Java / C# | バッチ | 参照先 |
| --- | --- | --- | --- |
| `s.slice(0,3)` | `s.substring(0,3)` | `%s:~0,3%` | [第2回 5章](02-control-flow.md#ch05) |
| `s.replaceAll("a","b")` | `s.replace("a","b")` | `%s:a=b%` | [第2回 5章](02-control-flow.md#ch05) |
| `s.includes("a")` | `s.contains("a")` | `if not "%s:a=%"=="%s%"` | [第2回 5章](02-control-flow.md#ch05) |
| `s.length` | `s.length()` | 直接はできない | [第2回 5章](02-control-flow.md#ch05) |
| 正規表現 | `Pattern` | `findstr /r`（限定的） | [早見表 8章](A2-cheatsheet.md#ch08) |
| `__dirname` | 実行パス取得 | `%~dp0` | [第3回 4章](03-practical.md#ch04) |
| `path.basename(p)` | `Path.GetFileName(p)` | `%~nx1` | [第1回 5章](01-execution-model.md#ch05) |
| `path.extname(p)` | `Path.GetExtension(p)` | `%~x1` | [第1回 5章](01-execution-model.md#ch05) |
| `JSON.parse` | JSON ライブラリ | **ない** | [第3回 9章](03-practical.md#ch09) |

### 引数・入出力・日時

| JS | Java / C# | バッチ | 参照先 |
| --- | --- | --- | --- |
| `process.argv[2]` | `args[0]` | `%~1` | [第1回 5章](01-execution-model.md#ch05) |
| `process.argv.slice(2)` | `args` | `%*` | [第1回 5章](01-execution-model.md#ch05) |
| `fs.readFileSync` | `Files.readAllLines` | `for /f` | [第2回 3章](02-control-flow.md#ch03) |
| `fs.writeFileSync` | `Files.write` | `echo … > file` | [早見表 7章](A2-cheatsheet.md#ch07) |
| `fs.existsSync` | `Files.exists` | `if exist` | [第2回 2章](02-control-flow.md#ch02) |
| ロガー | `Logger` | `>> log 2>&1` | [第3回 6章](03-practical.md#ch06) |
| `new Date()` | `LocalDateTime.now()` | PowerShell を呼ぶ | [第3回 3章](03-practical.md#ch03) |
| `child_process.exec` | `ProcessBuilder` | コマンドをそのまま書く | [第1回 2章](01-execution-model.md#ch02) |

> [!NOTE]
> **バッチに対応するものがない機能を見つけたら、それは設計を変える合図です。**この索引で「存在しない」「ない」と書かれている行（配列、JSON、正規表現、文字数）は、代用を書くこともできますが、書いた分だけ壊れやすくなります。[第3回 9章](03-practical.md#ch09)の4条件と照らして、バッチを続けるか判断してください。

<a id="ch03"></a>

## 3. 索引C: 症状からの逆引き

参照先の番号は[落とし穴カタログ](A3-pitfalls.md)の項番です。

### 値・変数がおかしい

| 症状 | まず疑うところ | 参照先 |
| --- | --- | --- |
| ループ内の出力が初期値のまま変わらない | `%VAR%` を `!VAR!` にする（遅延展開） | [#1](A3-pitfalls.md#p1) |
| 比較が成立しない | `set VAR = value` の空白 / 未定義変数 | [#2](A3-pitfalls.md#p2) |
| 値の末尾に空白が入っている | `set "名前=値"` の形にする | [#2](A3-pitfalls.md#p2) |
| `%VAR%` がそのまま表示される | 変数が未定義。置換できず元の文字列が残っている | [第1回 2章](01-execution-model.md#ch02) |
| `&` を含む値を `echo` したら壊れた | 展開結果が読み直されている。`!VAR!` で読む | [第2回 4章](02-control-flow.md#ch04) |
| 実行後、環境変数が書き換わっている | `setlocal` がない | [#13](A3-pitfalls.md#p13) |
| 拡張子なしのファイルで変な値になる | 空の変数に置換記法を使っている | [第2回 8章](02-control-flow.md#ch08) |

### エラーメッセージが出る

| メッセージ | まず疑うところ | 参照先 |
| --- | --- | --- |
| `この時点では予期されていません。` | 括弧・引用符・エスケープ（`&` `\|` `%`） | [#10](A3-pitfalls.md#p10) |
| `コマンドの構文が誤っています。` | 引用符 / 空白を含むパス / `::` を括弧内に書いた | [#5](A3-pitfalls.md#p5) [#9](A3-pitfalls.md#p9) |
| `指定されたパスが見つかりません。` | カレントディレクトリ / `%~dp0` の連結 | [#4](A3-pitfalls.md#p4) |
| `UNC パスはサポートされません。` | `cd` を `pushd` にする | [#14](A3-pitfalls.md#p14) |
| `パス演算子の次の使用方法は無効です` | `%~` の直後が修飾子になっていない（コメント行も対象） | [第1回 2章](01-execution-model.md#ch02) |
| ラベルが見つからない旨のメッセージ | `goto` 先のスペル / `::` の位置 | [#9](A3-pitfalls.md#p9) |
| `'…' は、内部コマンドまたは外部コマンド…` | 値の中の `&` が区切りとして解釈された | [第2回 4章](02-control-flow.md#ch04) |

### 表示・文字が壊れる

| 症状 | まず疑うところ | 参照先 |
| --- | --- | --- |
| 日本語が `?` や別の文字になる | ファイルの文字コード（SJIS + CRLF で保存する） | [#3](A3-pitfalls.md#p3) |
| 自分の環境では動くのに CI で化ける | コンソールのコードページ（65001 を継承している） | [#3](A3-pitfalls.md#p3) |
| 1行目でエラーになる | UTF-8 の BOM が付いている | [#3](A3-pitfalls.md#p3) |
| `%` が消える / 別の文字に化ける | バッチ内では `%%` と書く | [#10](A3-pitfalls.md#p10) |
| `!` が消える | 遅延展開が有効。`^^!` とエスケープする | [第2回 4章](02-control-flow.md#ch04) |
| ファイル名に空白が混じる | `%TIME%` の先頭空白。`%TIME: =0%` で置換する | [第3回 3章](03-practical.md#ch03) |

### 処理の流れがおかしい

| 症状 | まず疑うところ | 参照先 |
| --- | --- | --- |
| エラーが出ているのに処理が続行する | 終了コードを確認していない（例外はない） | [#6](A3-pitfalls.md#p6) |
| `if` の中の `%errorlevel%` が期待と違う | ブロック進入時の値に固定されている | [#7](A3-pitfalls.md#p7) |
| `robocopy` が成功なのに失敗と判定される | 1〜7 も成功。`if errorlevel 8` で判定する | [第3回 5章](03-practical.md#ch05) |
| 呼び出したバッチから戻ってこない | `call` を付けていない | [#12](A3-pitfalls.md#p12) |
| 最後のサブルーチンが余分に実行される | メイン処理の末尾に `goto :eof` がない | [第2回 6章](02-control-flow.md#ch06) |
| `else` を書いたら構文エラーになった | `)` `else` `(` を同じ行に置く | [第2回 2章](02-control-flow.md#ch02) |
| 実行後、ウィンドウが一瞬で閉じる | `exit` に `/b` がない / `pause` がない | [#8](A3-pitfalls.md#p8) |
| 無人実行で止まったまま進まない | `pause` が入っている | [第3回 4章](03-practical.md#ch04) |
| 引数解析が無限ループになる | `shift` の位置 | [第3回 7章](03-practical.md#ch07) |

### ファイル・パスの問題

| 症状 | まず疑うところ | 参照先 |
| --- | --- | --- |
| ダブルクリックでは動くのに別の場所からだと失敗する | カレントディレクトリを固定していない | [#4](A3-pitfalls.md#p4) |
| パスに空白が含まれると失敗する | 引用符の付け方（値には引用符を含めない） | [#5](A3-pitfalls.md#p5) |
| パスの区切りが `\\` になっている | `%~dp0` の末尾に `\` が付いている | [第3回 4章](03-practical.md#ch04) |
| `for /f` でファイル名が1行として処理される | 引用符を付けている。`usebackq` で意味を切り替える | [#11](A3-pitfalls.md#p11) |
| ログやバックアップでディスクが埋まる | 古いファイルの削除処理がない | [第3回 6章](03-practical.md#ch06) |
| 共有フォルダで動かない | `cd` ではなく `pushd` を使う | [#14](A3-pitfalls.md#p14) |

> [!NOTE]
> **症状から引けなかったときは `@echo off` を外してください。**実行される1行1行が**展開後の姿**で表示されるため、どの行でどう化けたかが直接見えます。バッチにはデバッガがないので、これが最も確実な調査手段です。

[← README に戻る](../README.md)
