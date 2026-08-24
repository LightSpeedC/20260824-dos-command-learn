# ============================================================
#  html2md.ps1
#   勉強会資料の HTML を Markdown に変換する
#   HTML は残したまま、同じ場所に .md を併設する
# ============================================================

$ErrorActionPreference = 'Stop'

# リポジトリのルート（このスクリプトから3つ上）
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path

# ---- HTML エンティティのデコード（& は最後） ----
function Decode-Entities([string]$s) {
	$s = $s -replace '&lt;', '<'
	$s = $s -replace '&gt;', '>'
	$s = $s -replace '&quot;', '"'
	$s = $s -replace '&#39;', "'"
	$s = $s -replace '&nbsp;', ' '
	$s = $s -replace '&amp;', '&'
	return $s
}

# ---- リンク先の .html を .md に付け替える ----
function Fix-Link([string]$href) {
	return ($href -replace '\.html($|#)', '.md$1')
}

# ---- インライン要素の変換（タグを除去して Markdown 記法にする） ----
function Convert-Inline([string]$s) {
	# セル内のコードブロックは1行のコード表記にする
	$s = [regex]::Replace($s, '(?s)<pre[^>]*>\s*<code>(.*?)</code>\s*</pre>', {
		param($m)
		'`' + (($m.Groups[1].Value -replace "`r?`n", '<br>') -replace '`', "'") + '`'
	})
	$s = [regex]::Replace($s, '(?s)<code>(.*?)</code>', {
		param($m) '`' + ($m.Groups[1].Value -replace '`', "'") + '`'
	})
	$s = $s -replace '(?s)<strong>(.*?)</strong>', '**$1**'
	$s = $s -replace '(?s)<em>(.*?)</em>', '*$1*'
	# バッジは角括弧付きの強調にする
	$s = $s -replace '(?s)<span class="badge b-[a-z]+">(.*?)</span>', '**[$1]** '
	# リンク
	$s = [regex]::Replace($s, '(?s)<a href="([^"]+)"[^>]*>(.*?)</a>', {
		param($m)
		'[' + ($m.Groups[2].Value -replace '<[^>]+>', '') + '](' + (Fix-Link $m.Groups[1].Value) + ')'
	})
	$s = $s -replace '<br\s*/?>', '<br>'
	# 残ったタグを除去
	$s = $s -replace '<[^>]+>', ''
	return $s
}

# ---- テーブルの変換 ----
function Convert-Table([string]$tableHtml) {
	$rows = [regex]::Matches($tableHtml, '(?s)<tr>(.*?)</tr>')
	$lines = @()
	$isFirst = $true
	foreach ($r in $rows) {
		$cells = @()
		foreach ($c in [regex]::Matches($r.Groups[1].Value, '(?s)<(th|td)[^>]*>(.*?)</\1>')) {
			$v = Convert-Inline $c.Groups[2].Value
			$v = $v -replace "`r?`n", ' '
			$v = $v -replace '\s+', ' '
			$v = $v -replace '\|', '\|'
			$cells += $v.Trim()
		}
		if ($cells.Count -eq 0) { continue }
		$lines += '| ' + ($cells -join ' | ') + ' |'
		if ($isFirst) {
			$lines += '| ' + (($cells | ForEach-Object { '---' }) -join ' | ') + ' |'
			$isFirst = $false
		}
	}
	return "`n" + ($lines -join "`n") + "`n"
}

# ---- 1ファイルの変換 ----
function Convert-File([string]$path) {
	$html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
	$htmlName = [System.IO.Path]::GetFileName($path)
	$script:hasMinibar = ($html -match '<div class="minibar">')

	# --- head と style を落とす ---
	$md = $html -replace '(?s)^.*?<body>', ''
	$md = $md -replace '(?s)</body>.*$', ''

	# --- タイトルバー ---
	$md = [regex]::Replace($md, '(?s)<div class="titlebar">\s*<div class="inner">\s*<h1>(.*?)</h1>\s*<p class="sub">(.*?)</p>\s*<p class="date">(.*?)</p>\s*</div>\s*</div>', {
		param($m)
		$title = Convert-Inline $m.Groups[1].Value
		$sub = Convert-Inline $m.Groups[2].Value
		$date = Convert-Inline $m.Groups[3].Value
		"`n# $title`n`n$sub`n`n$date`n"
	})

	# --- SVG は図の説明に置き換える（Markdown ではレンダリングされないため） ---
	$md = [regex]::Replace($md, '(?s)<svg[^>]*aria-label="([^"]*)"[^>]*>.*?</svg>', {
		param($m)
		"`n> **図:** " + $m.Groups[1].Value + " — 図は HTML 版（[$htmlName]($htmlName)）で表示されます`n"
	})
	$md = $md -replace '(?s)<svg[^>]*>.*?</svg>', ''

	# --- テーブル ---
	$md = [regex]::Replace($md, '(?s)<table>(.*?)</table>', { param($m) Convert-Table $m.Groups[1].Value })

	# --- ブロックレベルのコードは退避しておく ---
	$script:blocks = New-Object System.Collections.ArrayList
	$md = [regex]::Replace($md, '(?s)<pre[^>]*>\s*<code>(.*?)</code>\s*</pre>', {
		param($m)
		$i = $script:blocks.Add($m.Groups[1].Value)
		"%%CODE${i}%%"
	})

	# --- callout は引用にする ---
	$md = [regex]::Replace($md, '(?s)<div class="callout">\s*<p>(.*?)</p>\s*</div>', {
		param($m)
		$body = (Convert-Inline $m.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' '
		"`n> " + $body.Trim() + "`n"
	})

	# --- ミニタイトルバー（README で章の区切りに使っている） ---
	$md = [regex]::Replace($md, '(?s)<div class="minibar">(.*?)</div>', {
		param($m) "`n## " + (Convert-Inline $m.Groups[1].Value).Trim() + "`n"
	})

	# --- section の id はアンカーとして残す（GitHub は a タグの id を解釈する） ---
	$md = [regex]::Replace($md, '<section class="[^"]*" id="([^"]+)">', {
		param($m) "`n<a id=""" + $m.Groups[1].Value + """></a>`n"
	})
	$md = $md -replace '<section[^>]*>', ''
	$md = $md -replace '</section>', ''

	# --- 見出し（id 付きのものはアンカーを前に置く） ---
	# ミニタイトルバーがある文書は、その下に章が入るので1段深くする
	$script:h1 = if ($script:hasMinibar) { '### ' } else { '## ' }
	$script:h2 = if ($script:hasMinibar) { '#### ' } else { '### ' }
	$script:h3 = if ($script:hasMinibar) { '##### ' } else { '#### ' }
	$md = [regex]::Replace($md, '(?s)<h1>(.*?)</h1>', { param($m) "`n" + $script:h1 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })
	$md = [regex]::Replace($md, '(?s)<h2 id="([^"]+)">(.*?)</h2>', {
		param($m)
		"`n<a id=""" + $m.Groups[1].Value + """></a>`n`n" + $script:h2 + ((Convert-Inline $m.Groups[2].Value).Trim()) + "`n"
	})
	$md = [regex]::Replace($md, '(?s)<h2>(.*?)</h2>', { param($m) "`n" + $script:h2 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })
	$md = [regex]::Replace($md, '(?s)<h3>(.*?)</h3>', { param($m) "`n" + $script:h3 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })

	# --- リスト ---
	$md = [regex]::Replace($md, '(?s)<ol class="toc">(.*?)</ol>', {
		param($m)
		$items = [regex]::Matches($m.Groups[1].Value, '(?s)<li[^>]*>(.*?)</li>')
		$n = 0
		$out = foreach ($it in $items) { $n++; "$n. " + ((Convert-Inline $it.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim() }
		"`n" + ($out -join "`n") + "`n"
	})
	$md = [regex]::Replace($md, '(?s)<ol>(.*?)</ol>', {
		param($m)
		$items = [regex]::Matches($m.Groups[1].Value, '(?s)<li[^>]*>(.*?)</li>')
		$n = 0
		$out = foreach ($it in $items) { $n++; "$n. " + ((Convert-Inline $it.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim() }
		"`n" + ($out -join "`n") + "`n"
	})
	$md = [regex]::Replace($md, '(?s)<ul>(.*?)</ul>', {
		param($m)
		$items = [regex]::Matches($m.Groups[1].Value, '(?s)<li[^>]*>(.*?)</li>')
		$out = foreach ($it in $items) { "- " + ((Convert-Inline $it.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim() }
		"`n" + ($out -join "`n") + "`n"
	})

	# --- 段落 ---
	$md = [regex]::Replace($md, '(?s)<p[^>]*>(.*?)</p>', {
		param($m)
		"`n" + (((Convert-Inline $m.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim()) + "`n"
	})

	# --- 残りのタグを除去 ---
	$md = $md -replace '(?s)<footer>', ''
	$md = $md -replace '(?s)</footer>', ''
	$md = [regex]::Replace($md, '<(?!a id=|/a>)[^>]+>', '')

	# --- エンティティのデコード ---
	$md = Decode-Entities $md

	# --- コードブロックを戻す ---
	for ($i = 0; $i -lt $script:blocks.Count; $i++) {
		$code = Decode-Entities $script:blocks[$i]
		$code = $code -replace "`r`n", "`n"
		$fence = '```'
		$md = $md.Replace("%%CODE${i}%%", "`n$fence`n$code`n$fence`n")
	}

	# --- 空行を整理する ---
	$md = $md -replace "`r`n", "`n"
	$md = $md -replace "[ `t]+`n", "`n"
	$md = $md -replace "`n{3,}", "`n`n"
	$md = $md.Trim() + "`n"
	$md = $md -replace "`n", "`r`n"

	$out = [System.IO.Path]::ChangeExtension($path, '.md')
	[System.IO.File]::WriteAllText($out, $md, (New-Object System.Text.UTF8Encoding($false)))
	return $out
}

# ---- 実行 ----
$targets = Get-ChildItem -Path $root -Recurse -Filter *.html | Where-Object { $_.FullName -notlike '*\tmp\*' }
Write-Output ("変換対象: " + $targets.Count + " ファイル")
foreach ($t in $targets) {
	$out = Convert-File $t.FullName
	$size = (Get-Item $out).Length
	Write-Output ("  " + $out.Replace("$root\", '') + "  (" + $size + " バイト)")
}
Write-Output "変換が完了しました。"
