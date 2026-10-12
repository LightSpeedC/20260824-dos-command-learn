// サンプルの cmd を実行するテストの共通部品。
//
// 実行の決まり:
// - 窓を共有しないために windowsHide で起動する。新しい窓は OS 既定の 932 で始まるため、
//   呼び出し元の窓のコードページ（65001 のことがある）に左右されない。
// - 結果のファイルを作るサンプルがあるため、tmp/ に写して、その写しを実行する。
//   写すときは、実行で生まれる生成物（sorted・backup・log）を外す。未追跡のため、
//   クローンしたばかりの状態と同じにするため。
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';

export const projectDir = join(import.meta.dirname, '..');
const workRoot = join(projectDir, 'tmp', 'test-samples');
const decoder = new TextDecoder('shift_jis');
const generatedDirs = new Set(['sorted', 'backup', 'log']);
const createdDirs: string[] = [];
let runCount = 0;

export interface RunResult {
	lines: string[];
	stderr: string;
	exitCode: number | null;
	dir: string;
}

export interface RunOptions {
	// バッチへ渡す引数
	args?: string[];
	// 写しのフォルダへ足すファイル（ファイル名 → 中身）
	files?: Record<string, string>;
}

// pause の案内は言語で変わるため、最後の行が ". . ." で終わるものを外す
export function stripPause(text: string): string[] {
	const lines = text.split(/\r?\n/);
	while (lines.length > 0 && lines[lines.length - 1].trim() === '') lines.pop();
	if (lines.length > 0 && /\. \. \.\s*$/.test(lines[lines.length - 1])) lines.pop();
	return lines;
}

// sampleDir: docs/samples 配下のフォルダ名（01・02・templates）。そのフォルダごと tmp/ に写して実行する
export function runSample(sampleDir: string, fileName: string, options: RunOptions = {}): RunResult {
	runCount++;
	const dir = join(workRoot, `${sampleDir}-${fileName}-${process.pid}-${runCount}`);
	rmSync(dir, { recursive: true, force: true });
	mkdirSync(dir, { recursive: true });
	createdDirs.push(dir);
	cpSync(join(projectDir, 'docs', 'samples', sampleDir), dir, {
		recursive: true,
		filter: (src) => !generatedDirs.has(basename(src)),
	});
	for (const [name, body] of Object.entries(options.files ?? {})) {
		writeFileSync(join(dir, name), body);
	}
	// カレントの実行ファイルは名前だけでは見つからないことがあるため、.\ を付ける
	const r = spawnSync('cmd', ['/d', '/c', `.\\${fileName}`, ...(options.args ?? [])], {
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

// このテストファイルが作った写しだけを消す（並列で走る別のファイルの分は消さない）
export function cleanup(): void {
	for (const dir of createdDirs) rmSync(dir, { recursive: true, force: true });
	createdDirs.length = 0;
}

// 実行のたびに変わる値（日時など）を、正規表現で受ける。
// 期待値の配列は、文字列なら完全一致、正規表現なら一致で比べる。
export function expectLines(actual: string[], expected: (string | RegExp)[]): void {
	const shown = JSON.stringify(actual, null, 1);
	assert.equal(actual.length, expected.length, `行数が違う。実際の出力: ${shown}`);
	expected.forEach((want, i) => {
		if (typeof want === 'string') {
			assert.equal(actual[i], want, `${i + 1} 行目`);
		} else {
			assert.match(actual[i], want, `${i + 1} 行目`);
		}
	});
}

// 正規表現の中へ、フォルダなどの固定の文字列を埋めるときのエスケープ
export function escapeRegExp(text: string): string {
	return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// %DATE% と %TIME% の形（日本語の地域設定。サンプルがこの形を前提にしている）
export const DATE_PATTERN = '\\d{4}/\\d{2}/\\d{2}';
export const TIME_PATTERN = '[ \\d]\\d:\\d{2}:\\d{2}\\.\\d{2}';
export const STAMP_PATTERN = `\\[${DATE_PATTERN} ${TIME_PATTERN}\\]`;
