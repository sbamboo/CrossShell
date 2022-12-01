<#
  .SYNOPSIS
  Cmdlet for loading options/settings extracted from another session in a valid format.
#>

param($file)

if ($file) {
    if (test-path "$file") {
        $content = get-content "$file"
        foreach ($_ in $content) {
            [string]$line = $_
            $line = $line.trimend(',')
            [array]$lineA = $line.split(', ')
            $type = $lineA[0]
            [array]$nameA = $lineA[1].split(': ')
            $name = $nameA[0]
            $content = $nameA[1..($nameA.length)]
            $namespace = ($name.split('_'))[0]
            # State
            if ($type -eq "state") {
                if ($name -eq "title") {
                    CheckAndRun-input "title '$content'"
                } else {
                    saveState "$name" "$content" "$namespace"
                }
            }
        }
    } else {
        return "`e[31mFile not found.`e[0m"
    }
} else {
    return "`e[31mFile can't be null!`e[0m"
}