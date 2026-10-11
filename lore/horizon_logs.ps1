# Writes the Horizon Logs story text (and the final Welcome quest) into the lang snapshot, then run apply.ps1.
# The logs are the spine of the story; see STORY.md before changing them.
#   powershell -ExecutionPolicy Bypass -File branding\lore\horizon_logs.ps1
$ErrorActionPreference = 'Stop'
$base = Join-Path $PSScriptRoot 'base\en_us.snbt'
$utf8 = New-Object System.Text.UTF8Encoding $false

# id suffix (4D4841000000XXXX), title, subtitle, paragraphs ('' = blank line)
$logs = @(
  ,@('0000', 'The Grounding', 'From the logbook of Master Wright Ada Corrin', @(
    '&7&oIf you are reading this, the logbook found you, and I did not make it down.&r', '',
    'Three hundred years ago the Horizon Guild raised the Aerie, a city of brass and canvas that sailed above the clouds on a single machine: the Horizon Engine. Every discipline the Guild knew went into keeping it alive.', '',
    'Then came the night we call the Overclock. For eleven seconds the Aerie climbed faster than anything has ever climbed. Then it fell, and the world has been picking up the pieces ever since.', '',
    'They will tell you it was greed. It was not that simple. I was there. I plotted the course.', '',
    'Learn the old disciplines, apprentice, all of them. Each one you master unlocks another page of this log, and another piece of the truth.', '',
    '&6Each log unlocks when you reach a milestone in another chapter.&r'))
  ,@('0001', 'Log I: First Turn', 'Act I: The Cogwrights', @(
    'My teacher was Master Tobin Fell of the Cogwrights. On my first day he put a lump of andesite and an iron nugget in my hands and said: everything we build, we build from the humble up. I thought he was being poetic. He was giving me instructions.', '',
    'You have made your first alloy. Keep going. The Cogwrights taught the first language of machines, rotation, and everything after this is spoken in it.'))
  ,@('0002', 'Log II: Not a Tooth Out of Place', 'Act I: The Cogwrights', @(
    'Forty thousand precision mechanisms held the Aerie level. When one failed on my shift, the eastern quarter listed three degrees to port for a week, and the Guild never let me forget it.', '',
    'Here is what I did not know then: it was not my mechanism. They were failing all over the city, a few every month, for years. The Guild replaced them quietly and blamed the apprentices. Tobin noticed. Tobin always noticed.'))
  ,@('0003', 'Log III: The Wind Charter', 'Act I: The Windwrights', @(
    'The Wind Charter has one line: Anything properly built may leave the ground. Halvard Rook, the best pilot the Aerie ever had, used to add a second line under his breath: and anything that can leave the ground can go higher.', '',
    'He became Guildmaster when I was twenty. Under him the Aerie flew higher every year, and we thought it was ambition. You have built a vessel of your own now. Take it up and feel what it is like. Then remember that every climb has a ceiling.'))
  ,@('0004', 'Log IV: Lighter Than Reason', 'Act I: The Windwrights', @(
    'Levitite wants to rise the way water wants to fall. The Aerie''s foundations were poured from it on the pouring yards, foundry islands that floated beside the city.', '',
    'When the yards were retired, nobody could get them back down, so they were left to drift. They are still up there, high above the clouds. Anyone stubborn enough to live on one would have a very good view. Keep that in mind.'))
  ,@('0005', 'Log V: The Foundry Oath', 'Act II: The Warnings', @(
    'Foreman Bram Holt never trusted the Aerie and never set foot on it. A month before the Overclock, the Guildmaster sent him a refit order for the Engine''s cage. Bram sent it back unsigned, with one line written across it: this is a death sentence.', '',
    'Rook found another foundry. Bram''s steel held anyway: most of the survivors walked out of wreckage framed in Foundry girders. Make your steel the way he did.'))
  ,@('0006', 'Log VI: The Conduit Choir', 'Act II: The Warnings', @(
    'Cantor Liesl Marr could hear the Engine from anywhere in the city. For eleven years she said it was singing flat. She filed a report every season. Every one reached the Guildmaster''s desk, and not one was ever answered.', '',
    'I used to think she was exaggerating. Choir people always are. Learn to listen to your machines, apprentice. They will tell you when they are dying, if you let them.'))
  ,@('0007', 'Log VII: The Consortium Ledger', 'Act II: The Warnings', @(
    'Director Imra Vess kept the Consortium ledger like scripture. In the Aerie''s last years it showed something impossible: more fuel going into the Engine every season, and less power coming out.', '',
    'Vess circled the numbers in red and sent them to the Guildmaster. Then she raised her prices. She is the only one who wrote the truth down in plain figures, and the first to profit from keeping it quiet.'))
  ,@('0008', 'Log VIII: The Deep Works', 'Act II: The Warnings', @(
    'Ori, who founded the Deep Works, wired an off switch into every machine she ever built, running all the way to the surface. Contain everything, she said, including your own mistakes.', '',
    'A week before the Overclock, Warden Kael Brask removed the off switches from the Horizon Engine on the Guildmaster''s order, so that nobody could stop what came next halfway through. Build your reactor. Keep your off switch.'))
  ,@('0009', 'Log IX: Skyfall', 'Act III: The Truth', @(
    'You have seen the craters. The scholars call them meteorites. They are pieces of the Vault, the Aerie''s memory, and its sky stone shell rained across the world when we fell.', '',
    'On the last morning, Archivist Senna Quell read the Engine logs the Guildmaster had buried, understood what they meant and sealed copies into every cube in the Vault. Follow the compass. The truth is in the craters.'))
  ,@('000A', 'Log X: What the Vault Remembers', 'Act III: The Truth', @(
    'Wake the Vault and read what Senna saved: eleven years of Engine logs. The core was drifting. The Choir''s reports, the Consortium''s figures, the Deep Works readings, all of it on the Guildmaster''s desk and all of it buried.', '',
    'The Engine was dying, apprentice, and had been for eleven years. Rook knew. The Overclock was not greed. It was a desperate man trying to save a city that did not know it was falling.'))
  ,@('000B', 'Log XI: The Sky Roads', 'Act III: The Truth', @(
    'Rook''s chart had a line across it in red ink, far above any altitude a ship had reached. The Deep Works believed the Engine''s core would steady itself up there. They called it the horizon line.', '',
    'Someone had to plot the climb. I was the chief navigator. I ran the numbers four times and they never worked, and I signed the course anyway, because Rook asked me to and I could not think of anything better. This logbook is my confession. Now you know.'))
  ,@('000C', 'Log XII: The Overclock', 'Act III: The Truth', @(
    'The bridge, that night: Rook behind me. Director Vess at the throttles, pushing every one to its stop. Cantor Marr in the doorway, begging him to listen. The Engine singing a note nobody had ever heard.', '',
    'For eleven seconds the Aerie climbed. At the eighth, I knew we would never reach the line. At the tenth, I understood that if the core collapsed while it was still bolted to the city, the Aerie would not fall. It would vanish, all of it, into nothing.', '',
    'You have built a fusion reactor. You hold the same power we held that night. Use it better.'))
  ,@('000D', 'Log XIII: Event Horizon', 'Act III: The Truth', @(
    'So in the eleventh second, I cut the Engine''s heart loose from the city. That is why the Aerie fell instead of disappearing. That is why there were survivors to fall.', '',
    'The heart did not fall. Caught in levitite, it went up, toward the old pouring yards, and I went with it, because someone had to keep it balanced: gears to spin it, steel to cage it, crystal to tune it, industry to feed it, the Deep Works to contain it and the Vault to remember its shape. You have made a singularity of your own now. You know what that takes.'))
  ,@('0063', 'Beyond the Horizon', 'The last page', @(
    '&7&oThis page is newer than the others. The ink is still dark.&r', '',
    'If you have learned every discipline of the Guild, you have done what Rook never could: kept them all in balance, at the same time, in the same place.', '',
    'I did not make it down, apprentice. I went up. The heart is still beating above the old pouring yards, and I have kept it steady for longer than I like to count. I am tired.', '',
    'Build a ship that can climb past the clouds. Follow the light the pilots talk about. Come find me. I left the lamp on.', '',
    '&6&lWelcome to the Guild, Master Wright.&r'))
)

$entries = [ordered]@{}
foreach ($l in $logs) {
    $id = '4D484100' + $l[0].PadLeft(8, '0')
    $entries["quest.$id.title"] = """&6$($l[1])"""
    $entries["quest.$id.quest_subtitle"] = """$($l[2])"""
    $entries["quest.$id.quest_desc"] = '[' + (($l[3] | ForEach-Object { """$_""" }) -join ' ') + ']'
}
# the Welcome chapter's final quest
$entries['quest.11178481529B6D01.quest_subtitle'] = '"Every discipline, held in balance"'
$entries['quest.11178481529B6D01.quest_desc'] = '["Master all six disciplines of the Horizon Guild and hold them in balance at once. That is all the Horizon Engine ever needed, and the one thing the Guild forgot." "" "&7&oFinish this, then read the last page of the Horizon Logs.&r"]'

$text = [IO.File]::ReadAllText($base)
foreach ($k in $entries.Keys) {
    $line = "`t${k}: $($entries[$k])"
    $pattern = "(?m)^\t$([regex]::Escape($k)): .*$"
    if ([regex]::IsMatch($text, $pattern)) { $text = [regex]::Replace($text, $pattern, { param($m) $line }) }
    else { $end = $text.LastIndexOf('}'); $text = $text.Substring(0, $end).TrimEnd() + "`n$line`n}`n" }
}
[IO.File]::WriteAllText($base, $text, $utf8)
"updated $($entries.Count) entries"
