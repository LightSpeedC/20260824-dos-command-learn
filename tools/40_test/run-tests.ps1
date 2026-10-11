# docs/samples の cmd を実行して、出力を確かめる。
# 対象は絶対パスで渡す（渡さないと node はカレント配下の関係ないファイルまで実行する）
$ErrorActionPreference = 'Stop'

$testsDir = (Resolve-Path (Join-Path $PSScriptRoot '../../tests')).Path
if (-not $testsDir) { throw 'tests フォルダが見つかりません' }

Write-Host "node --test で実行します: $($testsDir.Replace($env:USERPROFILE, '~'))"
node --test $testsDir | Out-Host
$nodeExit = $LASTEXITCODE

$bunExit = 0
if (Get-Command bun -ErrorAction SilentlyContinue) {
	Write-Host 'bun test で実行します'
	bun test $testsDir | Out-Host
	$bunExit = $LASTEXITCODE
}

if ($nodeExit -ne 0 -or $bunExit -ne 0) {
	Write-Host "❌ 失敗 (node=$nodeExit, bun=$bunExit)"
	exit 1
}
Write-Host '✅ すべて通りました'
