# docs/ の資料に、前へ・次へ・目次のバッジを書き込む
# 本文の先頭とフッターの <!-- AUTO:nav --> 〜 <!-- /AUTO:nav --> を作り直す。
# リンク先のタイトルは、各資料のタイトルバーの h1 から取る。
$ErrorActionPreference = 'Stop'
$docs = (Resolve-Path "$PSScriptRoot/../../docs").Path
$enc = New-Object System.Text.UTF8Encoding($true)

$iconHome = '<svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true"><path fill="currentColor" d="M8 1 1 7h2v7h4v-4h2v4h4V7h2z"/></svg>'
$iconPrev = '<svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="2.2" d="M10 3 5 8l5 5"/></svg>'
$iconNext = '<svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="2.2" d="M6 3l5 5-5 5"/></svg>'

function Get-Title([string]$path) {
	$t = [IO.File]::ReadAllText($path)
	$m = [regex]::Match($t, '<div class="titlebar">[\s\S]*?<h1>([\s\S]*?)</h1>')
	if (-not $m.Success) { throw "タイトルバーの h1 が見つかりません: $path" }
	return ([regex]::Replace($m.Groups[1].Value, '<[^>]+>', '')).Trim()
}

function New-Link([string]$href, [string]$label, [string]$title, [string]$icon) {
	return "<a href=`"$href`" aria-label=`"$label`" title=`"$title`">$icon</a>"
}

# 本編は順に読むので前後をつなぐ。付録・構成は目次だけ
$main = @(Get-ChildItem $docs -Filter '0*.html' | Sort-Object Name)
$others = @(Get-ChildItem $docs -Filter '*.html' | Where-Object { $_.Name -match '^(A\d|ZZ)-' } | Sort-Object Name)

$targets = @()
for ($i = 0; $i -lt $main.Count; $i++) {
	$links = @(New-Link 'README.html' '目次' (Get-Title "$docs/README.html") $iconHome)
	if ($i -gt 0) { $p = $main[$i - 1]; $links = @(New-Link $p.Name '前へ' (Get-Title $p.FullName) $iconPrev) + $links }
	if ($i -lt $main.Count - 1) { $n = $main[$i + 1]; $links += New-Link $n.Name '次へ' (Get-Title $n.FullName) $iconNext }
	$targets += [pscustomobject]@{ Path = $main[$i].FullName; Links = $links }
}
foreach ($f in $others) {
	$targets += [pscustomobject]@{ Path = $f.FullName; Links = @(New-Link 'README.html' '目次' (Get-Title "$docs/README.html") $iconHome) }
}
# 資料一覧はプロジェクトの README へ、サンプルの説明は資料一覧へ戻る
$targets += [pscustomobject]@{ Path = "$docs/README.html"; Links = @(New-Link '../README.html' '戻る' 'README へ戻る' $iconHome) }
$targets += [pscustomobject]@{ Path = "$docs/samples/README.html"; Links = @(New-Link '../README.html' '目次' (Get-Title "$docs/README.html") $iconHome) }

foreach ($x in $targets) {
	$nav = "<!-- AUTO:nav -->`n<p class=`"docnav`">" + ($x.Links -join ' ') + "</p>`n<!-- /AUTO:nav -->"
	$t = [IO.File]::ReadAllText($x.Path)
	$o = $t
	if ($t -match '<!-- AUTO:nav -->') {
		$t = [regex]::Replace($t, '<!-- AUTO:nav -->[\s\S]*?<!-- /AUTO:nav -->', { param($m) $nav })
	} else {
		# 初回: 本文の先頭とフッターに差し込む
		$t = [regex]::Replace($t, '<p class="backlink">[\s\S]*?</p>\s*', '')
		$t = [regex]::Replace($t, '(<div class="wrap">\s*)', { param($m) $m.Groups[1].Value + $nav + "`n`n" }, 'None', [timespan]::FromSeconds(5))
		$t = [regex]::Replace($t, '<footer>[\s\S]*?</footer>', { param($m) "<footer>`n$nav`n</footer>" })
		if ($t -notmatch '<footer>') { $t = $t.Replace('</body>', "<footer>`n$nav`n</footer>`n`n</body>") }
	}
	if ($t -cne $o) { [IO.File]::WriteAllText($x.Path, $t, $enc); "更新: $($x.Path.Replace($docs, 'docs'))" }
}
