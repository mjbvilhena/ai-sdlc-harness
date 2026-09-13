# Shared helper for expanding {{SKILL_BODY}} / {{RULE_BODY}} from sibling CONTENT.md.
# Dot-sourced by install/install_*.ps1.

function Get-ItemPlaceholder {
    param([string]$ItemDir)
    $parent = Split-Path -Leaf (Split-Path -Parent $ItemDir)
    if ($parent -eq "rules") {
        return "{{RULE_BODY}}"
    }
    return "{{SKILL_BODY}}"
}

function Test-NoUnresolvedPlaceholders {
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    if ($text.Contains("{{SKILL_BODY}}") -or $text.Contains("{{RULE_BODY}}")) {
        throw "Error: unresolved placeholder remains in $Path. Refusing to install."
    }
}

function Expand-HarnessFile {
    param(
        [string]$ItemDir,
        [string]$SourceFile,
        [string]$DestFile,
        [string]$ItemName
    )

    $contentFile = Join-Path $ItemDir "CONTENT.md"
    if (-not (Test-Path -Path $contentFile -PathType Leaf)) {
        throw "Error: $ItemName is missing CONTENT.md (expected $contentFile)."
    }

    $placeholder = Get-ItemPlaceholder -ItemDir $ItemDir
    $template = [System.IO.File]::ReadAllText($SourceFile)
    if (-not $template.Contains($placeholder)) {
        throw "Error: $ItemName file $SourceFile is missing $placeholder."
    }

    $body = [System.IO.File]::ReadAllText($contentFile)
    $body = $body.TrimEnd("`r", "`n")

    $nl = if ($template.Contains("`r`n")) { "`r`n" } else { "`n" }
    $out = New-Object System.Text.StringBuilder
    $lines = $template.Split(@("`r`n", "`n"), [System.StringSplitOptions]::None)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        $isLast = ($i -eq $lines.Length - 1)
        if ($line.Trim() -eq $placeholder) {
            [void]$out.Append($body)
            if (-not $isLast) {
                [void]$out.Append($nl)
            }
            elseif ($template.EndsWith("`n")) {
                [void]$out.Append($nl)
            }
        }
        elseif ($line.Contains("{{SKILL_BODY}}") -or $line.Contains("{{RULE_BODY}}")) {
            throw "Error: $ItemName file $SourceFile must place $placeholder on its own line."
        }
        else {
            [void]$out.Append($line)
            if (-not $isLast) {
                [void]$out.Append($nl)
            }
            elseif ($template.EndsWith("`n") -and $line.Length -gt 0) {
                [void]$out.Append($nl)
            }
        }
    }

    $destDir = Split-Path -Parent $DestFile
    if (-not (Test-Path -Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($DestFile, $out.ToString(), $utf8NoBom)
    Test-NoUnresolvedPlaceholders -Path $DestFile
}

function Expand-HarnessDir {
    param(
        [string]$ItemDir,
        [string]$HarnessDir,
        [string]$DestDir,
        [string]$ItemName
    )

    $contentFile = Join-Path $ItemDir "CONTENT.md"
    if (-not (Test-Path -Path $contentFile -PathType Leaf)) {
        throw "Error: $ItemName is missing CONTENT.md (expected $contentFile)."
    }

    if (-not (Test-Path -Path $DestDir)) {
        New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    }

    $placeholder = Get-ItemPlaceholder -ItemDir $ItemDir
    $found = $false

    foreach ($entry in Get-ChildItem -Path $HarnessDir -Force) {
        $dest = Join-Path $DestDir $entry.Name
        if ($entry.PSIsContainer) {
            $hits = Get-ChildItem -Path $entry.FullName -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object {
                    $t = [System.IO.File]::ReadAllText($_.FullName)
                    $t.Contains("{{SKILL_BODY}}") -or $t.Contains("{{RULE_BODY}}")
                }
            if ($hits) {
                throw "Error: unresolved placeholder in companion directory $($entry.FullName). Refusing to install."
            }
            Copy-Item -Path $entry.FullName -Destination $dest -Recurse -Force
            continue
        }

        $text = [System.IO.File]::ReadAllText($entry.FullName)
        if ($text.Contains($placeholder)) {
            $found = $true
        }
        if ($text.Contains("{{SKILL_BODY}}") -or $text.Contains("{{RULE_BODY}}")) {
            Expand-HarnessFile -ItemDir $ItemDir -SourceFile $entry.FullName -DestFile $dest -ItemName $ItemName
        }
        else {
            Copy-Item -Path $entry.FullName -Destination $dest -Force
            Test-NoUnresolvedPlaceholders -Path $dest
        }
    }

    if (-not $found) {
        throw "Error: $ItemName harness dir $HarnessDir has no file containing $placeholder."
    }
}
