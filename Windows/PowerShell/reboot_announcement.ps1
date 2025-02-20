param(
    [Parameter(Mandatory=$true)]
    [int]$MinutesTillReboot,
    [Parameter(Mandatory=$true)]
    [int]$NumberOfWarnings,

    [string]$Message
)

$rebootAt = (Get-Date).AddMinutes($MinutesTillReboot)

$nextWarningAt = (Get-Date)
$warningIntervals = $MinutesTillReboot / $NumberOfWarnings

$now = Get-Date
$count = 0
while ($now -lt $rebootAt) {
    if ($now -ge $nextWarningAt ) {
        $count++
        $remainingTime = ($rebootAt - $now).Minutes
        $nextWarningAt = $nextWarningAt.AddMinutes($warningIntervals)
        msg * "($($count)/$($NumberOfWarnings)) Please, save your work and log off. This server will restart in $($remainingTime)min for maintenance."
    }
    Start-Sleep -Seconds 5
    $now = Get-Date
}
