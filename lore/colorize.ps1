# Colour scheme for quest descriptions, applied by apply.ps1 at build time (the snapshot stays plain).
#   gold  &6  item, block and machine names (Capitalised Phrases)
#   green &a  numbers and amounts            (32 EU/t, 80%, 8,192 IF/t)
#   aqua  &b  energy units on their own      (FE, RF, EU, AE, IF)
#   red   &c  redstone
#   yellow &e controls                       (Right-click, Sneak, ESC)
# Strings that already carry colour codes, lore lines and the Horizon Logs story text are left alone.

$script:ColorPattern = [regex]('(?<ctrl>\b(?:[Ss]neak-right-click|[Ss]hift-right-click|[Rr]ight-click(?:ing|ed|s)?|[Ll]eft-click(?:ing|ed|s)?|Ctrl-Scroll|Sneak|Shift|ESC)\b)' +
    '|(?<num>\b\d[\d,]*(?:\.\d+)?(?:k\b|x\b|(?:\s?(?:%|°|[kKM]?(?:EU|FE|RF|AE|IF)(?:/t)?\b|mb\b|mB\b|RPM\b|SU\b)))?)' +
    '|(?<unit>\b[kKM]?(?:EU|FE|RF|AE|IF)(?:/t)?\b)' +
    '|(?<red>\bredstone\b)' +
    '|(?<name>\b[A-Z][\w''-]*(?:\s(?:of\s|the\s)?[A-Z][\w''-]*)*)')

# words that start a sentence or phrase rather than belong to a name
$script:Lead = @('The','A','An','This','These','That','Each','Every','Its','It','Use','Using','Place','Put','Feed','Insert','Combine','Attach','Mix','Smelt',
    'Run','Build','Built','Connect','Power','Powered','Hold','Add','Apply','Crafted','Made','Produced','Required','Needed','Found','Your','With','When','If',
    'In','On','For','To','Unlike','Once','After','Before','Like','Without','Both','All','Higher','Lower','Get','Make','Set','Turn','Fill','Pour','Bind',
    'Link','Craft','Obtained','Smelted','Assembled','Alloyed','Cut','Mount','Throw','Grows','Generates','Stores','Converts','Consumes','Works','Functions',
    'Required','Right-click','Sneak','Shift','Then','Also','Most','Some','Any','No','Not','Only','Just','Here','There','You','They','We','He','She','Its',
    'Note','Tip','Hint','Click','Press','Open','Drop','Drag','Enter','Encase','Remove','Replace','Upgrade','Equip','Wear','Keep','Supply','Provide',
    'Requires','Accepts','Extracts','Charges','Transfers','Passes','Produces','Places','Detects','Senses','Splits','Refines','Compresses','Rotates')

# capitalised words that are not item or machine names
$script:NotNames = @('OK','UI','GUI','JEI','REI','EMI','Config','Enables','Promises','Endgame','Unbreakable','Hardness','PvP','Ponder','Minecraft','NeoForge','Forge')

function Colorize-Text([string]$s) {
    if (-not $s -or $s.Contains('&')) { return $s }
    $script:ColorPattern.Replace($s, [System.Text.RegularExpressions.MatchEvaluator] {
        param($m)
        if ($m.Groups['ctrl'].Success) { return "&e$($m.Value)&r" }
        if ($m.Groups['num'].Success) { return "&a$($m.Value)&r" }
        if ($m.Groups['unit'].Success) { return "&b$($m.Value)&r" }
        if ($m.Groups['red'].Success) { return "&c$($m.Value)&r" }
        # a name: peel off leading sentence words, then decide
        $words = $m.Value -split ' '
        $k = 0; while ($k -lt $words.Count -and $script:Lead -contains $words[$k]) { $k++ }
        if ($k -ge $words.Count) { return $m.Value }
        $prefix = if ($k) { ($words[0..($k - 1)] -join ' ') + ' ' } else { '' }
        $name = $words[$k..($words.Count - 1)] -join ' '
        if ($name -eq 'Redstone') { return "$prefix&c$name&r" }
        if ($name.Length -eq 1 -or $script:NotNames -contains $name) { return $m.Value }
        if ($name -in 'ESC', 'Sneak', 'Shift') { return "$prefix&e$name&r" }
        # a lone capitalised word at the start of a sentence is just grammar, not a name
        $before = $s.Substring(0, $m.Index).TrimEnd()
        if (-not $prefix -and $words.Count - $k -eq 1 -and ($before -eq '' -or $before -match '[.!?:]$')) { return $m.Value }
        return "$prefix&6$name&r"
    })
}

# colour every string inside the quest_desc values of a lang text, skipping the Horizon Logs (4D4841…)
function Colorize-Lang([string]$text) {
    $str = [regex]'"((?:[^"\\]|\\.)*)"'
    [regex]::Replace($text, '(?ms)^(\tquest\.([0-9A-F]{16})\.quest_desc: \[)(.*?)(\]\n)', [System.Text.RegularExpressions.MatchEvaluator] {
        param($m)
        if ($m.Groups[2].Value.StartsWith('4D4841')) { return $m.Value }
        $body = $str.Replace($m.Groups[3].Value, [System.Text.RegularExpressions.MatchEvaluator] { param($q) '"' + (Colorize-Text $q.Groups[1].Value) + '"' })
        $m.Groups[1].Value + $body + $m.Groups[4].Value
    })
}
