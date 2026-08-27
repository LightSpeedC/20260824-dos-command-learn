# ============================================================
#  html2md.ps1
#   勉強会資料の HTML を Markdown に変換する
#   HTML が原本。内容を直したらこのスクリプトで .md を作り直す
#
#   使い方: html2md.cmd をダブルクリックする
#
#   変換の方針:
#     - HTML は削除せず、同じ場所に .md を併設する
#     - インライン SVG は images/ に切り出して画像として参照する
#       （GitHub は Markdown 内のインライン SVG を除去するため）
#     - callout は GitHub の警告構文（> [!NOTE]）にする
#     - リンク先は .md に統一する
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
	# 色でしか区別していないバッジは、文字（角括弧付きの強調）に落とす
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

# ---- テーブルの変換（class="num" の列は右寄せにする） ----
function Convert-Table([string]$tableHtml) {
	$rows = [regex]::Matches($tableHtml, '(?s)<tr>(.*?)</tr>')
	$allRows = @()
	$numCols = @{}
	foreach ($r in $rows) {
		$cells = @()
		$idx = 0
		foreach ($c in [regex]::Matches($r.Groups[1].Value, '(?s)<(th|td)([^>]*)>(.*?)</\1>')) {
			if ($c.Groups[2].Value -match 'class="[^"]*\bnum\b[^"]*"') { $numCols[$idx] = $true }
			$v = Convert-Inline $c.Groups[3].Value
			$v = $v -replace "`r?`n", ' '
			$v = $v -replace '\s+', ' '
			$v = $v -replace '\|', '\|'
			$cells += $v.Trim()
			$idx++
		}
		if ($cells.Count -eq 0) { continue }
		$allRows += , $cells
	}
	if ($allRows.Count -eq 0) { return '' }

	$lines = @()
	$lines += '| ' + ($allRows[0] -join ' | ') + ' |'
	$sep = @()
	for ($i = 0; $i -lt $allRows[0].Count; $i++) {
		if ($numCols.ContainsKey($i)) { $sep += '---:' } else { $sep += '---' }
	}
	$lines += '| ' + ($sep -join ' | ') + ' |'
	for ($r = 1; $r -lt $allRows.Count; $r++) {
		$lines += '| ' + ($allRows[$r] -join ' | ') + ' |'
	}
	return "`n" + ($lines -join "`n") + "`n"
}

# ---- インライン SVG を独立ファイルに切り出す ----
#   GitHub は Markdown 内のインライン SVG をサニタイズで除去するため、
#   images/ に .svg として書き出して画像参照にする
function Export-Svg {
	param([string]$svgHtml, [string]$imgDir, [string]$baseName, [int]$no)

	$m = [regex]::Match($svgHtml, '(?s)<svg([^>]*)>(.*?)</svg>')
	if (-not $m.Success) { return $null }
	$attrs = $m.Groups[1].Value
	$body = $m.Groups[2].Value

	# viewBox から幅と高さを取る（単体ファイルとして開けるようにするため）
	$vb = [regex]::Match($attrs, 'viewBox="([^"]+)"')
	$w = 1000; $h = 300
	if ($vb.Success) {
		$nums = $vb.Groups[1].Value -split '\s+'
		if ($nums.Count -ge 4) { $w = $nums[2]; $h = $nums[3] }
	}
	$label = ''
	$lb = [regex]::Match($attrs, 'aria-label="([^"]*)"')
	if ($lb.Success) { $label = $lb.Groups[1].Value }

	$viewBox = if ($vb.Success) { $vb.Groups[1].Value } else { "0 0 $w $h" }

	# 白背景を最初に置く（透過のままだとダークモードで文字が読めない）
	$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox" width="$w" height="$h" role="img" aria-label="$label" font-family="Segoe UI, Yu Gothic UI, Meiryo, sans-serif">
<rect width="100%" height="100%" fill="#ffffff"/>
$body
</svg>
"@
	$svg = ($svg -replace "`r`n", "`n") -replace "`n", "`r`n"

	if (-not (Test-Path $imgDir)) { New-Item -ItemType Directory -Path $imgDir -Force | Out-Null }
	$fileName = "$baseName-fig$no.svg"
	[System.IO.File]::WriteAllText((Join-Path $imgDir $fileName), $svg, (New-Object System.Text.UTF8Encoding($false)))

	return [pscustomobject]@{ FileName = $fileName; Label = $label }
}

# ---- 1ファイルの変換 ----
function Convert-File([string]$path) {
	$html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
	$dir = [System.IO.Path]::GetDirectoryName($path)
	$baseName = [System.IO.Path]::GetFileNameWithoutExtension($path)
	$imgDir = Join-Path $dir 'images'
	$script:hasMinibar = ($html -match '<div class="minibar">')
	$script:sectionNo = 0
	$script:svgCount = 0

	# --- head と style を落とす ---
	$md = $html -replace '(?s)^.*?<body>', ''
	$md = $md -replace '(?s)</body>.*$', ''

	# --- タイトルバー（日付は引用行にする） ---
	$md = [regex]::Replace($md, '(?s)<div class="titlebar">\s*<div class="inner">\s*<h1>(.*?)</h1>\s*<p class="sub">(.*?)</p>\s*<p class="date">(.*?)</p>\s*</div>\s*</div>', {
		param($m)
		$title = (Convert-Inline $m.Groups[1].Value).Trim()
		$sub = ((Convert-Inline $m.Groups[2].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim()
		$date = ((Convert-Inline $m.Groups[3].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim()
		"`n# $title`n`n$sub`n`n> $date`n"
	})

	# --- インライン SVG を images/ に切り出して画像参照にする ---
	$md = [regex]::Replace($md, '(?s)<svg[^>]*>.*?</svg>', {
		param($m)
		$script:svgCount++
		$info = Export-Svg -svgHtml $m.Value -imgDir $imgDir -baseName $baseName -no $script:svgCount
		if ($null -eq $info) { return '' }
		"`n![" + $info.Label + "](images/" + $info.FileName + ")`n"
	})

	# --- テーブル ---
	$md = [regex]::Replace($md, '(?s)<table>(.*?)</table>', { param($m) Convert-Table $m.Groups[1].Value })

	# --- ブロックレベルのコードは退避しておく ---
	$script:blocks = New-Object System.Collections.ArrayList
	$md = [regex]::Replace($md, '(?s)<pre[^>]*>\s*<code>(.*?)</code>\s*</pre>', {
		param($m)
		$i = $script:blocks.Add($m.Groups[1].Value)
		"%%CODE${i}%%"
	})

	# --- callout は GitHub の警告構文にする ---
	$md = [regex]::Replace($md, '(?s)<div class="callout">\s*<p>(.*?)</p>\s*</div>', {
		param($m)
		$body = ((Convert-Inline $m.Groups[1].Value) -replace "`r?`n", ' ' -replace '\s+', ' ').Trim()
		"`n> [!NOTE]`n> " + $body + "`n"
	})

	# --- ミニタイトルバー（README で章の区切りに使っている） ---
	$md = [regex]::Replace($md, '(?s)<div class="minibar">(.*?)</div>', {
		param($m) "`n## " + (Convert-Inline $m.Groups[1].Value).Trim() + "`n"
	})

	# --- 見出しのレベル（ミニタイトルバーがある文書は1段深くする） ---
	$lv1 = if ($script:hasMinibar) { '### ' } else { '## ' }
	$lv2 = if ($script:hasMinibar) { '#### ' } else { '### ' }
	$lv3 = if ($script:hasMinibar) { '##### ' } else { '#### ' }

	# --- section の外にある見出し（目次・索引の案内など）は章と同じレベルにする ---
	#   いったん section を退避してから処理する
	$script:sections = New-Object System.Collections.ArrayList
	$md = [regex]::Replace($md, '(?s)<section class="[^"]*" id="[^"]+">.*?</section>', {
		param($m)
		$i = $script:sections.Add($m.Value)
		"%%SECT${i}%%"
	})
	$md = [regex]::Replace($md, '(?s)<h2>(.*?)</h2>', { param($m) "`n" + $lv1 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })
	$md = [regex]::Replace($md, '(?s)<h3>(.*?)</h3>', { param($m) "`n" + $lv2 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })
	for ($i = 0; $i -lt $script:sections.Count; $i++) {
		$md = $md.Replace("%%SECT${i}%%", $script:sections[$i])
	}

	# --- section の id はアンカーとして残す（GitHub は a タグの id を解釈する） ---
	$md = [regex]::Replace($md, '<section class="[^"]*" id="([^"]+)">', {
		param($m) "`n<a id=""" + $m.Groups[1].Value + """></a>`n"
	})
	$md = $md -replace '<section[^>]*>', ''
	$md = $md -replace '</section>', ''

	# --- 章と、section 内の見出し（章は番号を振る） ---
	$md = [regex]::Replace($md, '(?s)<h1>(.*?)</h1>', {
		param($m)
		$script:sectionNo++
		"`n" + $lv1 + $script:sectionNo + '. ' + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n"
	})
	$md = [regex]::Replace($md, '(?s)<h2 id="([^"]+)">(.*?)</h2>', {
		param($m)
		"`n<a id=""" + $m.Groups[1].Value + """></a>`n`n" + $lv2 + ((Convert-Inline $m.Groups[2].Value).Trim()) + "`n"
	})
	$md = [regex]::Replace($md, '(?s)<h2>(.*?)</h2>', { param($m) "`n" + $lv2 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })
	$md = [regex]::Replace($md, '(?s)<h3>(.*?)</h3>', { param($m) "`n" + $lv3 + ((Convert-Inline $m.Groups[1].Value).Trim()) + "`n" })

	# --- リスト ---
	$md = [regex]::Replace($md, '(?s)<ol[^>]*>(.*?)</ol>', {
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
	$md = $md -replace '(?s)</?footer>', ''
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
	return [pscustomobject]@{ Path = $out; Svg = $script:svgCount }
}

# ---- 実行 ----
# index.html は README.html へのリダイレクト専用なので変換しない
$targets = Get-ChildItem -Path $root -Recurse -Filter *.html |
	Where-Object { $_.FullName -notlike '*\tmp\*' -and $_.Name -ne 'index.html' }
Write-Output ("変換対象: " + $targets.Count + " ファイル")
$totalSvg = 0
foreach ($t in $targets) {
	$r = Convert-File $t.FullName
	$size = (Get-Item $r.Path).Length
	$totalSvg += $r.Svg
	$note = if ($r.Svg -gt 0) { "  SVG $($r.Svg)枚を切り出し" } else { '' }
	Write-Output ("  " + $r.Path.Replace("$root\", '') + "  (" + $size + " バイト)" + $note)
}
Write-Output ("変換が完了しました。切り出した SVG: " + $totalSvg + " 枚")
