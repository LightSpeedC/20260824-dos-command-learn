// docs/samples の cmd を実際に実行し、出力が期待どおりかを確かめる。
//
// 期待値は、サンプルを読んで手で書いたもの。実行結果から作らない。
// 資料に載せた出力とサンプルがずれたとき、ここで落ちて気づけるようにするのが目的。
//
// 実行の決まり:
// - 窓を共有しないために windowsHide で起動する。新しい窓は OS 既定の 932 で始まるため、
//   呼び出し元の窓のコードページ（65001 のことがある）に左右されない。
// - 結果のファイルを作るサンプルがあるため、tmp/ に写して、その写しを実行する。
// - 日時・フォルダの絶対パスなど、実行のたびに変わる行は比較から外す。
import { after, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, rmSync } from 'node:fs';
import { join } from 'node:path';

const projectDir = join(import.meta.dirname, '..');
const workRoot = join(projectDir, 'tmp', 'test-samples');
const decoder = new TextDecoder('shift_jis');

interface RunResult {
	lines: string[];
	stderr: string;
	exitCode: number | null;
	dir: string;
}

// pause の案内は言語で変わるため、最後の行が ". . ." で終わるものを外す
function stripPause(text: string): string[] {
	const lines = text.split(/\r?\n/);
	while (lines.length > 0 && lines[lines.length - 1].trim() === '') lines.pop();
	if (lines.length > 0 && /\. \. \.\s*$/.test(lines[lines.length - 1])) lines.pop();
	return lines;
}

// sampleDir: docs/samples 配下のフォルダ名（01・02）。そのフォルダごと tmp/ に写して実行する
function runSample(sampleDir: string, fileName: string): RunResult {
	const dir = join(workRoot, `${sampleDir}-${fileName}-${process.pid}`);
	rmSync(dir, { recursive: true, force: true });
	mkdirSync(dir, { recursive: true });
	cpSync(join(projectDir, 'docs', 'samples', sampleDir), dir, { recursive: true });
	// カレントの実行ファイルは名前だけでは見つからないことがあるため、.\ を付ける
	const r = spawnSync('cmd', ['/d', '/c', `.\\${fileName}`], {
		cwd: dir,
		windowsHide: true,
		stdio: ['ignore', 'pipe', 'pipe'],
		timeout: 30000,
	});
	return {
		lines: stripPause(decoder.decode(r.stdout)),
		stderr: decoder.decode(r.stderr),
		exitCode: r.status,
		dir,
	};
}

after(() => {
	rmSync(workRoot, { recursive: true, force: true });
});

describe('実行環境', () => {
	test('新しい窓のコードページは 932（以降の期待値は SJIS で読む前提）', () => {
		const r = spawnSync('cmd', ['/d', '/c', 'chcp'], {
			windowsHide: true,
			stdio: ['ignore', 'pipe', 'pipe'],
			timeout: 30000,
		});
		assert.match(decoder.decode(r.stdout), /932/);
	});
});

describe('第1回のサンプル', () => {
	test('01-hello: echo は表示し、rem は表示しない', () => {
		const r = runSample('01', '01-hello.cmd');
		assert.deepEqual(r.lines, [
			'こんにちは',
			'',
			'上の行は echo. で空行を出しています',
			'終わりです',
		]);
	});

	test('02-expand: 未定義の変数は黙って空になる', () => {
		const r = runSample('01', '02-expand.cmd');
		assert.equal(r.lines[0], '=== 1. 未定義の変数は黙って空になる ===');
		assert.equal(r.lines[1], '[]');
	});

	test('02-expand: set の書き方で、変数名に空白が入る', () => {
		const r = runSample('01', '02-expand.cmd');
		assert.ok(r.lines.includes('NAME1=[太郎]'));
		assert.ok(r.lines.includes('NAME2=[太郎]'));
		// NAME3 は変数名が "NAME3 " になり、読むと空になる
		assert.ok(r.lines.includes('NAME3=[]'));
		assert.ok(r.lines.includes('NAME3 = 太郎'));
	});

	test('02-expand: 値はすべて文字列で、set /a のときだけ計算される', () => {
		const r = runSample('01', '02-expand.cmd');
		assert.ok(r.lines.includes('5 + 3 は 53'));
		assert.ok(r.lines.includes('set /a を使うと 8'));
	});

	test('02-expand: & を含む値は、遅延展開なら壊れず、通常の展開では壊れる', () => {
		const r = runSample('01', '02-expand.cmd');
		assert.ok(r.lines.includes('B: Hello & World'));
		assert.ok(r.lines.includes('C: "Hello & World"'));
		// A: は & の後ろが別のコマンドとして実行され、World が見つからずエラーになる
		// echo A: Hello & World の & の手前の空白は、そのまま出る
		assert.ok(r.lines.includes('A: Hello '));
		assert.match(r.stderr, /'World'/);
	});

	test('03-errorlevel: 成功は 0、失敗は 1。&& と || と、以上の判定', () => {
		const r = runSample('01', '03-errorlevel.cmd');
		assert.deepEqual(r.lines, [
			'=== 1. 成功するコマンド ===',
			'errorlevel=0',
			'',
			'=== 2. 失敗するコマンド ===',
			'errorlevel=1',
			'',
			'=== 3. && と || ===',
			'成功したときだけ実行:',
			'  -> 成功しました',
			'失敗したときだけ実行:',
			'  -> 失敗しました',
			'',
			'=== 4. if errorlevel は「その値以上」 ===',
			'終了コード=3',
			'  if errorlevel 1 相当は真（3 は 1 以上）',
			'  if errorlevel 5 相当は偽（3 は 5 未満）',
		]);
	});
});

describe('第2回のサンプル', () => {
	// フォルダにある cmd の数と並び（名前順）。サンプルを足したらここも直す
	const cmdNames = [
		'01-delayed-ng.cmd',
		'01-delayed-ok.cmd',
		'02-if.cmd',
		'03-for.cmd',
		'04-string.cmd',
		'05-subroutine.cmd',
		'06-sort.cmd',
	];

	test('01-delayed-ng: ブロックの中では 0 に焼き付き、外では正しい値になる', () => {
		const r = runSample('02', '01-delayed-ng.cmd');
		assert.deepEqual(r.lines, [
			'=== カレントのファイルを数える（失敗版） ===',
			...cmdNames.map(() => '現在: 0   ... 通常の展開なので 0 のまま'),
			'',
			`ループの外では正しい値になる: ${cmdNames.length}`,
			'',
			'理由: 括弧ブロックは1つの論理行。中に入る前に全体が1回だけ',
			'      置換されるため、ブロック内の表示は 0 に焼き付いている',
		]);
	});

	test('01-delayed-ok: 遅延展開なら、ブロックの中でも値が増えていく', () => {
		const r = runSample('02', '01-delayed-ok.cmd');
		assert.deepEqual(r.lines, [
			'=== カレントのファイルを数える（修正版） ===',
			...cmdNames.map((name, i) => `現在: ${i + 1}   ${name} = ${name}`),
			'',
			`合計: ${cmdNames.length} 件`,
			'',
			'=== 遅延展開のもう1つの役割: 再解析を止める ===',
			'B: Hello & World',
			'  通常の展開だと & がコマンド区切りとして働いて壊れる',
			'  （01-delayed-ng.cmd ではなく 02-expand.cmd 第1回 で確認できる）',
		]);
	});

	test('02-if: 文字列比較・存在確認・定義確認・数値比較・else', () => {
		const r = runSample('02', '02-if.cmd');
		assert.deepEqual(r.lines, [
			'=== 1. 文字列比較 ===',
			'  MODE は test です',
			'  /i を付けると大文字小文字を区別しない',
			'  not で否定できる',
			'',
			'=== 2. 両辺を引用符で囲む理由 ===',
			'  EMPTY は未定義。引用符があれば構文が壊れない:',
			'  不一致と正しく判定された',
			'',
			'=== 3. 存在確認 ===',
			'  このフォルダは存在します',
			'  notexist_xyz.txt はありません',
			'  フォルダを確かめたいときは末尾にバックスラッシュを付ける',
			'',
			'=== 4. 変数の定義 ===',
			'  MODE は定義されています（パーセントで囲まない）',
			'  UNDEFINED_XYZ は未定義です',
			'',
			'=== 5. 数値比較 ===',
			'  7 は 5 以上（GEQ）',
			'  7 は 10 未満（LSS）',
			'  == は文字列比較なので "05" と "5" は不一致になる:',
			'  不一致',
			'  set /a を通せば EQU で一致する',
			'',
			'=== 6. else は同じ行に置く ===',
			'  テストモード',
			'  閉じ括弧と else と開き括弧を別の行に分けると構文エラーになる',
		]);
	});

	test('04-string: 部分取得・置換・含有判定・末尾の除去・ループ内の置換', () => {
		const r = runSample('02', '04-string.cmd');
		// DATE は実行した日で変わるため、その 5 行（先頭の空白 2 つ＋見出し）は外す
		const skip = /^ {2}(DATE の生の値|区切りを削除|年 |月 |日 )/;
		assert.deepEqual(r.lines.filter((line) => !skip.test(line)), [
			'=== 部分取得（V=abcdefg） ===',
			'  先頭3文字        = abc',
			'  3文字目から末尾  = defg',
			'  末尾2文字        = fg',
			'  末尾2文字を除く  = abcde',
			'',
			'=== 置換 ===',
			'  abc を X に      = Xdefg',
			'  abc を削除       = defg',
			'',
			'=== 含有判定（削除して変化があれば含んでいた） ===',
			'  cde を含みます',
			'  xyz を含みません',
			'',
			'=== 末尾のバックスラッシュを取り除く ===',
			'  処理前 = C:\\work\\data\\',
			'  処理後 = C:\\work\\data',
			'',
			'=== 日付を組み立てる（地域設定に依存する） ===',
			'  この方法は環境依存。確実な方法は第3回で扱う',
			'',
			'=== ループ内では遅延展開の形で書く ===',
			'  alpha の先頭2文字 = al',
			'  beta の先頭2文字 = be',
			'  gamma の先頭2文字 = ga',
			'  ループ変数に直接は置換記法を使えないため、いったん変数に入れる',
		]);
	});

	test('06-sort: 拡張子ごとに振り分け、拡張子の無い LICENSE は noext に入る', () => {
		const r = runSample('02', '06-sort.cmd');
		// 先頭の「対象:」「保存先:」は絶対パスを含むため外す
		const body = r.lines.filter((line) => !/^(対象|保存先): /.test(line));
		assert.deepEqual(body, [
			'',
			'  OK   access.log -> log\\',
			'  OK   error.log -> log\\',
			'  OK   image.png -> png\\',
			'  OK   LICENSE -> noext\\',
			'  OK   memo.txt -> txt\\',
			'  OK   readme.txt -> txt\\',
			'',
			'コピー成功: 6 件 / 失敗: 0 件',
		]);
		assert.equal(r.exitCode, 0);
		assert.ok(existsSync(join(r.dir, 'sorted', 'noext', 'LICENSE')));
		assert.ok(existsSync(join(r.dir, 'sorted', 'log', 'access.log')));
	});

	test('06-sort: 存在しないフォルダを渡すとエラーで終了コード 1', () => {
		const dir = join(workRoot, `02-06-sort-missing-${process.pid}`);
		rmSync(dir, { recursive: true, force: true });
		mkdirSync(dir, { recursive: true });
		cpSync(join(projectDir, 'docs', 'samples', '02'), dir, { recursive: true });
		const r = spawnSync('cmd', ['/d', '/c', '.\\06-sort.cmd', 'notexist_dir_xyz'], {
			cwd: dir,
			windowsHide: true,
			stdio: ['ignore', 'pipe', 'pipe'],
			timeout: 30000,
		});
		assert.equal(r.status, 1);
		assert.ok(stripPause(decoder.decode(r.stdout))[0].startsWith('[エラー] フォルダが見つかりません: '));
	});
});
