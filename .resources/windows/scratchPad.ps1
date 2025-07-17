pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -InputFormat Text -OutputFormat Text -WindowStyle Normal -CommandWithArgs @'
    $vars = Get-Variable

    Write-Host "Dumplings $args[1] dummy jump"

    # return ($vars | ConvertTo-Json)
'@
Sabs Sucks