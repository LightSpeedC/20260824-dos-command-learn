// 資料に載せたエラーメッセージが、実機の出力と同じかを確かめる。
//
// 期待値は、公式のロケール資源（cmd.exe.mui）と実機の出力を見て手で書いたもの。
// 資料の文言が独自の訳にずれていたことが、実機の出力との突き合わせで見つかったため置く。
// 実行の決まりは samples.test.ts と同じ（windowsHide で新しい窓を使い、932 で読む）。
import { after, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const projectDir = join(import.meta.dirname, '..');
const workDir = join(projectDir, 'tmp', `test-messages-${process.pid}`);
const decoder = new TextDecoder('shift_jis');

// 日本語環境でしか通らない。英語環境では日本語の文言と比べられない
function runBatch(body: string): string[] {
	mkdirSync(workDir, { recursive: true });
	writeFileSync(join(workDir, 't.cmd'), `@echo off\r\n${body}\r\n`);
	const r = spawnSync('cmd', ['/d', '/c', '.\\t.cmd'], {
		cwd: workDir,
		windowsHide: true,
		stdio: ['ignore', 'pipe', 'pipe'],
		timeout: 30000,
	});
	return decoder.decode(Buffer.concat([r.stdout, r.stderr])).split(/\r?\n/);
}

function readDoc(name: string): string {
	return readFileSync(join(projectDir, 'docs', name), 'utf8');
}

after(() => {
	rmSync(workDir, { recursive: true, force: true });
});

describe('エラーメッセージ（実機の出力と資料の文言）', () => {
	test('rem 行の %~ に空白が続くと、公式の文言で止まり、末尾は「構文が誤っています」', () => {
		const lines = runBatch('rem a %~ b');
		assert.equal(lines[0], 'バッチ パラメーターの置き換えで、パス演算子の次の使用法は無効です: ');
		assert.equal(lines[1], '%~ b');
		assert.equal(lines[4], '有効な形式については、「CALL /?」または「FOR /?」と入力してください。');
		assert.equal(lines[5], 'コマンドの構文が誤っています。');
		assert.ok(readDoc('01-実行モデル.html').includes('\nコマンドの構文が誤っています。</code></pre>'));
		assert.ok(!readDoc('01-実行モデル.html').includes('構文が正しくありません'));
	});

	test('閉じ括弧の後ろに余計な語があると「x の使い方が誤っています。」になる', () => {
		const lines = runBatch('if 1==1 (\r\necho a\r\n) x');
		assert.equal(lines[0], 'x の使い方が誤っています。');
		// 英語の原文は "x was unexpected at this time."。「この時点では予期されていません」は公式の訳ではない
		for (const name of ['A1-逆引き参照.html', 'ZZ-構成.html']) {
			const doc = readDoc(name);
			assert.ok(doc.includes('… の使い方が誤っています。'), name);
			assert.ok(!doc.includes('この時点では予期されていません'), name);
		}
	});
});
