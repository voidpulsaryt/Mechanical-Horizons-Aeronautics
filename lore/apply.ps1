# Adds one italic lore line to the top of each quest description.
# Reads branding\lore\*.txt (QUEST_ID|line) and rebuilds the quest lang file from the
# pre-lore snapshot in branding\lore\base\en_us.snbt, so it is safe to run again after editing any lore file.
#   powershell -ExecutionPolicy Bypass -File branding\lore\apply.ps1
param([string]$Out)
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$base = Join-Path $PSScriptRoot 'base\en_us.snbt'
$live = if ($Out) { $Out } else { Join-Path $root 'config\ftbquests\quests\lang\en_us.snbt' }
$utf8 = New-Object System.Text.UTF8Encoding $false

$questIds = @{}
foreach ($f in Get-ChildItem (Join-Path $root 'config\ftbquests\quests\chapters\*.snbt')) {
    foreach ($m in [regex]::Matches([IO.File]::ReadAllText($f.FullName), '(?m)^\t\t\tid: "([0-9A-F]{16})"')) { $questIds[$m.Groups[1].Value] = $f.BaseName }
}

$text = [IO.File]::ReadAllText($base)
# colour item names, numbers, units, redstone and controls (see colorize.ps1)
. (Join-Path $PSScriptRoot 'colorize.ps1')
$text = Colorize-Lang $text
$added = New-Object System.Collections.Generic.List[string]
$count = 0; $problems = @()
foreach ($file in Get-ChildItem (Join-Path $PSScriptRoot '*.txt')) {
    foreach ($raw in [IO.File]::ReadAllLines($file.FullName)) {
        if ($raw -match '^\s*(#|$)') { continue }
        $id, $line = $raw -split '\|', 2
        $id = $id.Trim(); $line = $line.Trim()
        if (-not $questIds.ContainsKey($id)) { $problems += "$($file.Name): unknown quest $id"; continue }
        if ($line -match '["\\&]') { $problems += "$($file.Name): $id uses a forbidden character (quote, backslash or ampersand)"; continue }
        $lore = """&7&o$line&r"""
        $key = "quest.$id.quest_desc: ["
        $i = $text.IndexOf($key)
        if ($i -ge 0) {
            $at = $i + $key.Length
            # an empty description is replaced outright; otherwise lore, blank line, original text
            if ($text.Substring($at, 3) -eq '""]') { $text = $text.Remove($at, 2).Insert($at, $lore) }
            elseif ($text[$at] -eq "`n") { $text = $text.Insert($at, "`n`t`t$lore`n`t`t" + '""') }
            else { $text = $text.Insert($at, "$lore """" ") }
        } else {
            $added.Add("`tquest.$id.quest_desc: [$lore]")
        }
        $count++
    }
}
if ($added.Count) {
    $end = $text.LastIndexOf('}')
    $text = $text.Substring(0, $end).TrimEnd() + "`n" + ($added -join "`n") + "`n}`n"
}
[IO.File]::WriteAllText($live, $text, $utf8)
"Applied $count lore lines ($($added.Count) quests had no description)."
$problems
& (Join-Path $PSScriptRoot 'check_lang.ps1') -File $live
