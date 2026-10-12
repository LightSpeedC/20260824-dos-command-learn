// 資料の中の、数え直しが要る記述が実態とずれていないかを確かめる。
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const projectDir = join(import.meta.dirname, '..');

function read(path: string): string {
	return readFileSync(join(projectDir, path), 'utf8');
}

describe('落とし穴カタログの項目数', () => {
	const a3 = read('docs/A3-落とし穴.html');
	// 項目の見出し（h2 の id="pN"）を数える
	const count = [...a3.matchAll(/<h2 id="p(\d+)">/g)].length;

	test('見出し 15 件が、1 から 15 まで連番で並んでいる', () => {
		const numbers = [...a3.matchAll(/<h2 id="p(\d+)">/g)].map((m) => Number(m[1])).sort((a, b) => a - b);
		assert.deepEqual(numbers, Array.from({ length: numbers.length }, (_, i) => i + 1));
		assert.equal(count, 15);
	});

	test('A3 の副題・README・ZZ の「N項目」が、見出しの数と同じ', () => {
		for (const path of ['docs/A3-落とし穴.html', 'README.html', 'docs/ZZ-構成.html']) {
			const match = read(path).match(/(\d+)項目/);
			assert.ok(match, `${path} に「N項目」が無い`);
			assert.equal(Number(match[1]), count, path);
		}
	});

	test('症状から探す表が、すべての項目へリンクしている', () => {
		for (let n = 1; n <= count; n++) {
			assert.ok(a3.includes(`<a href="#p${n}">${n}</a>`), `#${n} が症状の表に無い`);
		}
	});
});
