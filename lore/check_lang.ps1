# Parses the quest lang file the way FTB Quests does (an SNBT compound of key: "string" or key: ["string" ...])
# and reports the first error with its line and column. Also checks every chapter has a title.
#   powershell -ExecutionPolicy Bypass -File branding\lore\check_lang.ps1
param([string]$File)
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$file = if ($File) { $File } else { Join-Path $root 'config\ftbquests\quests\lang\en_us.snbt' }
$s = [IO.File]::ReadAllText($file)
$i = 0; $n = $s.Length; $keys = 0; $seen = @{}
function Fail([string]$msg) { $pre = $s.Substring(0, [math]::Min($i, $n)); $line = ($pre -split "`n").Count; $col = $i - $pre.LastIndexOf("`n"); throw "line ${line}:${col}: $msg" }
function Ws { while ($script:i -lt $n -and " `t`r`n,".Contains($s[$script:i])) { $script:i++ } }
function Str {
    if ($s[$script:i] -ne '"') { Fail "expected a quoted string" }
    $script:i++
    while ($script:i -lt $n -and $s[$script:i] -ne '"') { if ($s[$script:i] -eq '\') { $script:i++ }; if ($s[$script:i] -eq "`n") { Fail 'line break inside a string' }; $script:i++ }
    if ($script:i -ge $n) { Fail 'unterminated string' }
    $script:i++
}
try {
    Ws; if ($s[$i] -ne '{') { Fail "file must start with {" }; $i++
    while ($true) {
        Ws; if ($i -ge $n) { Fail 'missing closing }' }
        if ($s[$i] -eq '}') { $i++; break }
        $k0 = $i; while ($i -lt $n -and $s[$i] -notmatch '[\s:]') { $i++ }
        $key = $s.Substring($k0, $i - $k0); if (-not $key) { Fail 'expected a key' }
        if ($seen[$key]) { Fail "duplicate key $key" }; $seen[$key] = $true
        Ws; if ($s[$i] -ne ':') { Fail "expected ':' after $key" }; $i++; Ws
        if ($s[$i] -eq '[') { $i++; Ws; while ($s[$i] -ne ']') { Str; Ws }; $i++ } else { Str }
        $keys++
    }
    Ws; if ($i -lt $n) { Fail 'text after the closing }' }
    "OK: $keys entries parse cleanly"
} catch { "PARSE ERROR $_"; exit 1 }

$chapters = Join-Path $root 'config\ftbquests\quests\chapters\*.snbt'
foreach ($f in Get-ChildItem $chapters) {
    $id = [regex]::Match([IO.File]::ReadAllText($f.FullName), '(?m)^\tid: "([0-9A-F]{16})"').Groups[1].Value
    if (-not $seen["chapter.$id.title"]) { "MISSING chapter title: $($f.BaseName) ($id)" }
}
