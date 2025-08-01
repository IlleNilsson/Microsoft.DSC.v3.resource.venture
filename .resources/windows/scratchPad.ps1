dsc -l trace resource get -r Visity.DSC.Windows/Feature

dsc -l trace config test -f ./visity.dsc.config.yaml

pwsh -NoLogo -NonInteractive -NoProfile -NoProfileLoadTime -InputFormat Text -OutputFormat Text -WindowStyle Normal -CommandWithArgs @'
    $vars = Get-Variable

    Write-Host "Dumplings '$($args[0])' dummy jump '$($args[1])'"

    return ($vars | ConvertTo-Yaml)
'@ Arg1 Arg2

