pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -InputFormat Text -OutputFormat Text -WindowStyle Normal -CommandWithArgs @'
    $vars = Get-Variable

    Write-Host "Dumplings '$($args[0])' dummy jump '$($args[1])'"

    return ($vars | ConvertTo-Yaml)
'@ Arg1 Arg2