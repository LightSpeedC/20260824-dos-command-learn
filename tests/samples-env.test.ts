// docs/samples のうち、実行のたびに変わる値（日時・絶対パス・引数）を含むサンプルを確かめる。
//
// 期待値は、サンプルを読んで手で書いたもの。実行結果から作らない。
// 変わる値は正規表現で受ける。expectLines は、文字列なら完全一致、正規表現なら一致で比べる。
// 実行の決まりは helpers.ts に書いてある。
import { after, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';
import {
	cleanup,
	DATE_PATTERN,
	escapeRegExp,
	expectLines,
	runSample,
	STAMP_PATTERN,
	TIME_PATTERN,
} from './helpers.ts';

after(cleanup);

const decoder = new TextDecoder('shift_jis');

// サンプルが書いたログを読む（SJIS）
function readLog(path: string): string[] {
	return decoder.decode(readFileSync(path)).split(/\r?\n/).filter((line) => line !== '');
}

function findOne(dir: string, pattern: RegExp): string {
	const names = readdirSync(dir).filter((name) => pattern.test(name));
	assert.equal(names.length, 1, `${pattern} に合うファイルが 1 つのはず: ${names.join(', ')}`);
	return join(dir, names[0]);
}

describe('第1回: 04-args（引数とチルダ修飾子）', () => {
	test('引数を渡すと、%0 %1 %* とチルダ修飾子の値が表示される', () => {
		const r = runSample('01', '04-args.cmd', { args: ['sample.txt', 'abc'] });
		const file = join(r.dir, 'sample.txt');
		const drive = r.dir.slice(0, 2);
		const path = r.dir.slice(2) + '\\';
		expectLines(r.lines, [
			'=== 引数そのもの ===',
			'%0   = .\\04-args.cmd',
			'%1   = sample.txt',
			'%~1  = sample.txt',
			'%*   = sample.txt abc',
			'',
			'=== チルダ修飾子（%1 に対して） ===',
			`%~f1  フルパス       = ${file}`,
			`%~d1  ドライブ       = ${drive}`,
			`%~p1  パス           = ${path}`,
			`%~dp1 ドライブ+パス  = ${drive}${path}`,
			'%~n1  名前           = sample',
			'%~x1  拡張子         = .txt',
			'%~nx1 名前+拡張子    = sample.txt',
			// 更新日時は写したときに変わる。形だけ見る
			new RegExp(`^%~t1  更新日時       = ${DATE_PATTERN} \\d{2}:\\d{2}$`),
			`%~z1  サイズ         = ${statSync(file).size}`,
			'',
			'=== 自分の場所とカレントは別物 ===',
			`%~dp0 = ${r.dir}\\`,
			`%CD%   = ${r.dir}`,
		]);
	});

	test('引数なしは使い方を表示して終了コード 1', () => {
		const r = runSample('01', '04-args.cmd');
		expectLines(r.lines, [
			'使い方: 04-args.cmd <ファイルパス> [追加の引数...]',
			'',
			`例: 04-args.cmd "${r.dir}\\sample.txt" abc`,
		]);
		assert.equal(r.exitCode, 1);
	});
});

describe('第1回: 05-backup（日付付きでコピー）', () => {
	test('指定したファイルが、今日の日付（yyyymmdd）付きの名前で backup に入る', () => {
		const r = runSample('01', '05-backup.cmd', { args: ['sample.txt'] });
		expectLines(r.lines, [new RegExp(`^完了: ${escapeRegExp(r.dir)}\\\\backup\\\\\\d{8}_sample\\.txt$`)]);
		assert.equal(r.exitCode, 0);
		assert.ok(existsSync(findOne(join(r.dir, 'backup'), /^\d{8}_sample\.txt$/)));
	});

	test('存在しないファイルを渡すとエラーで終了コード 1', () => {
		const r = runSample('01', '05-backup.cmd', { args: ['notexist_xyz.txt'] });
		expectLines(r.lines, ['[エラー] コピー元が見つかりません: notexist_xyz.txt']);
		assert.equal(r.exitCode, 1);
	});

	test('引数なしは使い方を表示して終了コード 1', () => {
		const r = runSample('01', '05-backup.cmd');
		expectLines(r.lines, ['使い方: 05-backup.cmd <バックアップするファイル>']);
		assert.equal(r.exitCode, 1);
	});
});

describe('第2回: 03-for（for の4つの形）', () => {
	test('11 の形を順に回し、ファイル名・行・CSV・サブフォルダ・break の代わりを確かめる', () => {
		const r = runSample('02', '03-for.cmd');
		expectLines(r.lines, [
			'=== 1. 無印: ファイル名を回す ===',
			'  01-delayed-ng.cmd',
			'  01-delayed-ok.cmd',
			'  02-if.cmd',
			'  03-for.cmd',
			'  04-string.cmd',
			'  05-subroutine.cmd',
			'  06-sort.cmd',
			'',
			'=== 2. 無印: 空白区切りの単語を回す（配列の代用） ===',
			'  [alpha]',
			'  [beta]',
			'  [gamma]',
			'',
			'=== 3. /l: 回数ループ ===',
			'  1',
			'  2',
			'  3',
			'  4',
			'  5',
			'  逆順（増分を負にする）:',
			'  3',
			'  2',
			'  1',
			'',
			'=== 4. /f: ファイルの各行を読む ===',
			'  --- 引用符なし: ファイルの中身を読む ---',
			'  1行目のデータです',
			'  2行目のデータです',
			'  3行目のデータです',
			'  --- 引用符あり: 文字列そのものになってしまう ---',
			'  data.txt',
			'',
			'=== 5. /f: usebackq で空白を含むパスを読む ===',
			'  空白を含むファイル名のデータです',
			'  usebackq が必要な例',
			'',
			'=== 6. /f: tokens と delims でCSVを分解 ===',
			'  名前=山田 / 部署=営業 / 年齢=32',
			'  名前=鈴木 / 部署=開発 / 年齢=28',
			'  名前=佐藤 / 部署=総務 / 年齢=45',
			'',
			'=== 7. /f: コマンドの出力を読む ===',
			'  list.csv',
			'',
			'=== 8. /d: フォルダのみ ===',
			'  [DIR] testfiles',
			'',
			'=== 9. /r: サブフォルダも含める ===',
			'  memo.txt',
			'  readme.txt',
			'',
			'=== 10. ループ変数にもチルダ修飾子が使える ===',
			`  フルパス = ${r.dir}\\list.csv`,
			'  名前     = list',
			'  拡張子   = .csv',
			'  サイズ   = 58',
			'',
			'=== 11. break はない。goto で抜ける ===',
			'  1',
			'  2',
			'  3',
			'  3 で抜けました',
		]);
		assert.equal(r.exitCode, 0);
	});
});

describe('第2回: 05-subroutine（サブルーチンと戻り値）', () => {
	test('日時付きのログ、終了コードで返す形、変数で返す形が動く', () => {
		const r = runSample('02', '05-subroutine.cmd');
		const log = (message: string) => new RegExp(`^\\[${TIME_PATTERN}\\] ${message}$`);
		expectLines(r.lines, [
			log('処理を開始します'),
			'',
			'=== 方法1: 終了コードで返す（真偽値） ===',
			'  sample.txt はテキストです',
			'  sample.log はテキストではない',
			'',
			'=== 方法2: 変数に書き込んで返す ===',
			'  拡張子は .xlsx です',
			'  拡張子は .gz です',
			'',
			'=== サブルーチンは複数回呼べる ===',
			log('処理中: alpha'),
			log('処理中: beta'),
			log('処理中: gamma'),
			log('処理が完了しました'),
		]);
	});
});

describe('第3回: 01-datetime（日時を取得する3つの方法）', () => {
	// wmic は Windows 11 の新しい版で削除されている
	const hasWmic = spawnSync('where', ['wmic'], { windowsHide: true, stdio: 'ignore', timeout: 30000 }).status === 0;

	test('方法1 と方法3 は yyyymmdd_hhmmss の形になる。方法2 の wmic は無い環境では空になる', () => {
		const r = runSample('03', '01-datetime.cmd');
		expectLines(r.lines, [
			'=== 生の値（そのまま使うと壊れる） ===',
			new RegExp(`^ {2}DATE = \\[${DATE_PATTERN}\\]$`),
			new RegExp(`^ {2}TIME = \\[${TIME_PATTERN}\\]$`),
			'  TIME は時が1桁だと先頭が空白になる。コロンとピリオドはファイル名に使えない',
			'',
			'=== 方法1: PowerShell を呼ぶ（推奨） ===',
			/^ {2}結果 = \[\d{8}_\d{6}\]$/,
			'  書式を明示するので地域設定に依存しない。起動に数百ミリ秒かかる',
			'',
			'=== 方法2: wmic を使う（非推奨） ===',
			hasWmic ? /^ {2}生の値 = \[\d{14}\.\d{6}[+-]\d{3}\]$/ : /^ {2}生の値 = \[\]$/,
			'  末尾に余分な文字が混入するため、部分取得で必要な桁だけ切り出す',
			// wmic が無いと LDT が未定義のまま部分取得の記法が展開され、崩れた文字列になる（i261012-02）。
			// 崩れ方は環境しだいなので、wmic が無いときは行頭だけを見る
			hasWmic ? /^ {2}結果 {3}= \[\d{8}_\d{6}\]$/ : /^ {2}結果 {3}= \[/,
			'  wmic は非推奨。将来の Windows で削除される予定',
			'',
			'=== 方法3: DATE と TIME を加工（地域依存） ===',
			/^ {2}結果 = \[\d{8}_\d{6}\]$/,
			'  外部プロセスを起動しないので高速。ただし地域設定に依存する',
			'',
			'=== 結論 ===',
			'  配布するバッチ         -> 方法1',
			'  自分専用の使い捨て     -> 方法3',
			'  既存コードの保守のみ   -> 方法2',
		]);
	});
});

describe('第3回: 02-errorhandling（エラー処理の型）', () => {
	test('失敗しても次の行は動く。md は既存で失敗、robocopy の 1 は成功。後始末で何も残らない', () => {
		const r = runSample('03', '02-errorhandling.cmd');
		expectLines(r.lines, [
			'=== 1. 失敗しても次の行は実行される（例外がない） ===',
			'  copy は失敗したが、この行は実行されている（errorlevel=1）',
			'',
			'=== 2. 失敗したら止める基本形 ===',
			'  [エラー] コピーに失敗しました  ... ここで exit /b するのが基本形',
			'',
			'=== 3. 事前確認で弾く ===',
			'  [エラー] 対象が見つかりません: notexist_xyz.txt',
			'  実行して失敗させるより、先に確認したほうがメッセージが分かりやすい',
			'',
			'=== 4. md は既存フォルダでエラーになる ===',
			'  1回目: errorlevel=0',
			'  2回目: errorlevel=1  ... 既存なので失敗する',
			'  失敗しても構わない場合は 2>nul でエラー出力だけ捨てて続行する',
			'',
			'=== 5. robocopy は 1?7 も成功 ===',
			'  robocopy の終了コード = 1',
			'  成功（8 未満は成功扱い）。|| で判定すると誤検知する',
			'',
			'=== 6. 後始末を確実に通す ===',
			'  :finish ラベルに goto で合流させると、成功・失敗の両方で通せる',
			'  後始末を実行中...',
			'  後始末が完了しました',
		]);
		assert.equal(r.exitCode, 0);
		for (const name of ['robosrc', 'robodst', 'testdir']) {
			assert.ok(!existsSync(join(r.dir, name)), `${name} が残っている`);
		}
	});
});

describe('第3回: 03-logging（ログ出力とリダイレクトの順序）', () => {
	test('2>&1 を先に書くとエラーが画面に残る。正しい順序のエラーはログに入る', () => {
		const r = runSample('03', '03-logging.cmd');
		const stamp = (message: string) => new RegExp(`^${STAMP_PATTERN} ${message}$`);
		expectLines(r.lines, [
			'=== リダイレクトの順序の違いを確認する ===',
			'  正しい形: 先にファイルへ向けてから 2>&1 と書く',
			'  -> エラーはログに入り、画面には何も出ない',
			'  誤った形: 2>&1 を先に書くとエラーが画面に残る',
			'  （この下にエラーメッセージが表示されます）',
			// 2>&1 は「そのときの標準出力」へ向ける。先に書くと、ファイルではなく画面側（標準出力）へ出る
			'指定されたファイルが見つかりません。',
			'',
			'=== 画面とログの両方に出す ===',
			stamp('==== 処理を開始します ===='),
			'',
			'=== サブルーチン全体の出力をログへ回す ===',
			'  :main の出力はすべてログへ入った（画面には出ていない）',
			stamp('==== 正常終了しました ===='),
			'',
			'=== 生成されたログ ===',
			new RegExp(`^ {2}${escapeRegExp(r.dir)}\\\\log\\\\demo_\\d{8}\\.log$`),
			// ここから type で表示されるログの中身。echo 行は ">>" の手前の空白が行末に残る
			'指定されたファイルが見つかりません。',
			new RegExp(`^${STAMP_PATTERN} ==== 処理を開始します ==== $`),
			'本処理を実行中...',
			'この行もログにだけ入る',
			new RegExp(`^${STAMP_PATTERN} ==== 正常終了しました ==== $`),
		]);
		assert.equal(r.exitCode, 0);
		// どちらのエラーも標準エラーには出ない（正しい形はログへ、誤った形は標準出力へ）
		assert.equal(r.stderr, '');
		assert.equal(readLog(findOne(join(r.dir, 'log'), /^demo_\d{8}\.log$/)).length, 5);
	});
});

describe('第3回: 04-args（引数解析とヘルプ）', () => {
	const usage = [
		'使い方: 04-args.cmd [-v] [-o 出力先] <対象パス>',
		'',
		'  <対象パス>   処理するファイルまたはフォルダ',
		'  -v           詳細を表示する',
		'  -o 出力先    出力先を指定する',
		'  -h, --help   このヘルプを表示する',
	];
	const tail = [
		'',
		'shift の位置を1つ間違えると無限ループになる。',
		'オプションが3つ以上になるなら、バッチ以外を検討する合図。',
	];

	test('-v と -o の値と対象を解析する', () => {
		const r = runSample('03', '04-args.cmd', { args: ['-v', '-o', 'out.txt', 'target.txt'] });
		expectLines(r.lines, [
			'=== 解析結果 ===',
			'  対象     = [target.txt]',
			'  詳細表示 = 有効',
			'  出力先   = [out.txt]',
			...tail,
		]);
		assert.equal(r.exitCode, 0);
	});

	test('対象だけなら、詳細表示は無効・出力先は未指定', () => {
		const r = runSample('03', '04-args.cmd', { args: ['target.txt'] });
		expectLines(r.lines, [
			'=== 解析結果 ===',
			'  対象     = [target.txt]',
			'  詳細表示 = 無効',
			'  出力先   = 未指定',
			...tail,
		]);
	});

	test('対象が無いと、エラーに続けて使い方を表示して終了コード 1', () => {
		const r = runSample('03', '04-args.cmd', { args: ['-v'] });
		expectLines(r.lines, ['[エラー] 対象を指定してください', '', ...usage]);
		assert.equal(r.exitCode, 1);
	});

	test('引数なし・/? ・ --help は、同じ使い方を表示して終了コード 1', () => {
		for (const args of [[], ['/?'], ['--help'], ['-H']]) {
			const r = runSample('03', '04-args.cmd', { args });
			expectLines(r.lines, usage);
			assert.equal(r.exitCode, 1, `引数 ${JSON.stringify(args)}`);
		}
	});
});

describe('第3回: 05-backup（配布可能な最終版）', () => {
	const start = (name: string) => `==== 開始: ${name} ====`;

	test('コピーに成功すると、画面・ログ・backup に記録が残る', () => {
		const r = runSample('03', '05-backup.cmd', { args: ['sample.txt'] });
		expectLines(r.lines, [
			start('sample.txt'),
			new RegExp(`^完了: ${escapeRegExp(r.dir)}\\\\backup\\\\\\d{8}_\\d{6}_sample\\.txt$`),
			'==== 正常終了 ====',
		]);
		assert.equal(r.exitCode, 0);
		assert.ok(existsSync(findOne(join(r.dir, 'backup'), /^\d{8}_\d{6}_sample\.txt$/)));
		const log = readLog(findOne(join(r.dir, 'log'), /^backup_\d{8}\.log$/));
		assert.equal(log.length, 3);
		assert.match(log[0], new RegExp(`^${STAMP_PATTERN} ${start('sample.txt')} $`));
	});

	test('-v を付けるとコピー先も表示する', () => {
		const r = runSample('03', '05-backup.cmd', { args: ['-v', 'sample.txt'] });
		expectLines(r.lines, [
			start('sample.txt'),
			new RegExp(`^コピー先: ${escapeRegExp(r.dir)}\\\\backup\\\\\\d{8}_\\d{6}_sample\\.txt$`),
			new RegExp(`^完了: ${escapeRegExp(r.dir)}\\\\backup\\\\\\d{8}_\\d{6}_sample\\.txt$`),
			'==== 正常終了 ====',
		]);
	});

	test('存在しないファイルは、異常終了（終了コード 1）として記録される', () => {
		const r = runSample('03', '05-backup.cmd', { args: ['notexist_xyz.txt'] });
		expectLines(r.lines, [
			start('notexist_xyz.txt'),
			'[エラー] コピー元が見つかりません: notexist_xyz.txt',
			'==== 異常終了 終了コード=1 ====',
		]);
		assert.equal(r.exitCode, 1);
	});

	test('-v だけで対象が無いときも、使い方に出るのは shift 前のファイル名', () => {
		// shift は %0 もずらす。控えておかないと「使い方: -v …」になる
		const r = runSample('03', '05-backup.cmd', { args: ['-v'] });
		assert.equal(r.lines[0], '使い方: 05-backup.cmd [-v] <バックアップするファイル>');
		assert.equal(r.exitCode, 1);
	});

	test('引数なしは使い方を表示して終了コード 1', () => {
		const r = runSample('03', '05-backup.cmd');
		expectLines(r.lines, [
			'使い方: 05-backup.cmd [-v] <バックアップするファイル>',
			'',
			'  <ファイル>   バックアップ対象',
			'  -v           詳細を表示する',
			'',
			'保存先: このバッチと同じ場所の backup フォルダ',
			'ログ  : このバッチと同じ場所の log フォルダ',
		]);
		assert.equal(r.exitCode, 1);
	});
});

describe('テンプレート', () => {
	test('tool: 対象が存在すれば本処理を呼んで 0 で終わる。オプションも表示される', () => {
		const r = runSample('templates', 'tool.cmd', { args: ['tool.cmd', '-x'] });
		expectLines(r.lines, ['対象: tool.cmd', 'オプション: -x', '完了しました。']);
		assert.equal(r.exitCode, 0);
	});

	test('tool: 対象が無いとエラーで終了コード 1。引数なしは使い方', () => {
		const missing = runSample('templates', 'tool.cmd', { args: ['notexist_xyz'] });
		expectLines(missing.lines, ['[エラー] 対象が見つかりません: notexist_xyz']);
		assert.equal(missing.exitCode, 1);

		const none = runSample('templates', 'tool.cmd');
		expectLines(none.lines, [
			'使い方: tool.cmd <対象パス> [オプション]',
			'',
			'  対象パス    処理するファイルまたはフォルダ',
			'  オプション  省略可',
		]);
		assert.equal(none.exitCode, 1);
	});

	test('launcher: 起動対象（main.ps1）が無いとエラーで終了コード 1', () => {
		const r = runSample('templates', 'launcher.cmd');
		expectLines(r.lines, ['[エラー] 起動対象が見つかりません: main.ps1']);
		assert.equal(r.exitCode, 1);
	});

	test('launcher: 引数をそのまま ps1 へ渡し、ps1 の終了コードを返す', () => {
		const r = runSample('templates', 'launcher.cmd', {
			args: ['a', 'b'],
			files: { 'main.ps1': 'Write-Output ("arg=" + ($args -join ","))\r\nexit 3\r\n' },
		});
		expectLines(r.lines, ['arg=a,b', '[エラー] 終了コード: 3']);
		assert.equal(r.exitCode, 3);
	});

	test('batchjob: 開始と終了を画面とログに残し、本処理の出力はログだけに入る', () => {
		const r = runSample('templates', 'batchjob.cmd');
		const stamp = (message: string) => new RegExp(`^${STAMP_PATTERN} ${message}$`);
		expectLines(r.lines, [stamp('==== 処理を開始します ===='), stamp('==== 正常終了しました ====')]);
		assert.equal(r.exitCode, 0);
		const log = readLog(findOne(join(r.dir, 'log'), /^job_\d{8}\.log$/));
		assert.equal(log.length, 3);
		assert.match(log[0], new RegExp(`^${STAMP_PATTERN} ==== 処理を開始します ==== $`));
		assert.equal(log[1], '本処理を実行中...');
		assert.match(log[2], new RegExp(`^${STAMP_PATTERN} ==== 正常終了しました ==== $`));
	});
});
