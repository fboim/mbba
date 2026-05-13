$content = Get-Content 'C:\Users\AM SERVICE\mbba\src\frontend\pages\materi.html' -Raw
$match = [regex]::Match($content, '(?s)<script>(.+?)</script>\s*</body>')
if ($match.Success) {
    $js = $match.Groups[1].Value
    $js | Out-File -Encoding utf8 -FilePath $env:TEMP\mbba_materi.js
    Write-Host "JS length: $($js.Length) chars"

    $opens = ($js.ToCharArray() | Where-Object { $_ -eq '{' }).Count
    $closes = ($js.ToCharArray() | Where-Object { $_ -eq '}' }).Count
    Write-Host "Braces: { = $opens, } = $closes, diff = $($opens - $closes)"

    $paren_open = ($js.ToCharArray() | Where-Object { $_ -eq '(' }).Count
    $paren_close = ($js.ToCharArray() | Where-Object { $_ -eq ')' }).Count
    Write-Host "Parens: ( = $paren_open, ) = $paren_close, diff = $($paren_open - $paren_close)"

    $funcMatches = [regex]::Matches($js, 'function\s+\w+')
    Write-Host "Function declarations: $($funcMatches.Count)"
    foreach ($m in $funcMatches) {
        Write-Host "  - $($m.Value)"
    }

    # Check for IIFE at start
    $first200 = $js.Substring(0, [Math]::Min(200, $js.Length))
    Write-Host "Script first 200 chars: $first200"

    # Check for script tag inside js
    if ($js -match '</script') {
        Write-Host "WARNING: </script found inside JS!"
    }

    Remove-Item $env:TEMP\mbba_materi.js -EA SilentlyContinue
} else {
    Write-Host "Could not extract script block"
}
