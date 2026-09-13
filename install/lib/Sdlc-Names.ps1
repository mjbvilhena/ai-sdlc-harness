# Shared sdlc- destination naming and cleanup helpers.
# Dot-sourced by install/install_*.ps1.

function Get-SdlcPrefixedName {
    param([string]$Name)
    if ($Name.StartsWith("sdlc-")) {
        return $Name
    }
    return "sdlc-$Name"
}

# Rewrite the first YAML frontmatter `name:` key to DestName, if present.
function Set-SdlcFrontmatterName {
    param(
        [string]$File,
        [string]$DestName
    )

    if (-not (Test-Path -Path $File -PathType Leaf)) {
        return
    }

    $text = [System.IO.File]::ReadAllText($File)
    $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = $text.Split(@("`r`n", "`n"), [System.StringSplitOptions]::None)
    if ($lines.Length -eq 0 -or $lines[0].TrimEnd("`r") -ne "---") {
        return
    }

    $out = New-Object System.Text.StringBuilder
    $inFm = $true
    $seenName = $false
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $raw = $lines[$i].TrimEnd("`r")
        $isLast = ($i -eq $lines.Length - 1)
        $emit = $raw

        if ($i -gt 0 -and $inFm) {
            if ($raw -eq "---") {
                $inFm = $false
            }
            elseif (-not $seenName -and $raw -match '^name:\s*') {
                $emit = "name: $DestName"
                $seenName = $true
            }
        }

        [void]$out.Append($emit)
        if (-not $isLast) {
            [void]$out.Append($nl)
        }
        elseif ($text.EndsWith("`n")) {
            [void]$out.Append($nl)
        }
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($File, $out.ToString(), $utf8NoBom)
}

function Set-SdlcFrontmatterNamesInDir {
    param(
        [string]$DestDir,
        [string]$DestName
    )

    if (-not (Test-Path -Path $DestDir -PathType Container)) {
        return
    }

    Get-ChildItem -Path $DestDir -File -Force | ForEach-Object {
        Set-SdlcFrontmatterName -File $_.FullName -DestName $DestName
    }
}

# Remove sdlc-* files matching Filter (e.g. "sdlc-*.md") under DestDir.
function Remove-SdlcFiles {
    param(
        [string]$DestDir,
        [string]$Filter,
        [bool]$DryRun = $false
    )

    if (-not (Test-Path -Path $DestDir -PathType Container)) {
        Write-Host "  [info] Destination $DestDir does not exist yet — nothing to clean."
        return
    }

    Write-Host "Cleaning previously installed sdlc-* artifacts in $DestDir..."
    $items = @(Get-ChildItem -Path $DestDir -File -Filter $Filter -ErrorAction SilentlyContinue)
    if ($items.Count -eq 0) {
        Write-Host "  [info] No sdlc-* artifacts to remove."
        return
    }

    foreach ($item in $items) {
        if ($DryRun) {
            Write-Host "  [dry-run] Would remove: $($item.FullName)"
        }
        else {
            Remove-Item -Path $item.FullName -Force
            Write-Host "  [ok] Removed: $($item.FullName)"
        }
    }
}

# Remove sdlc-* directories under DestDir (Antigravity skill folders).
function Remove-SdlcDirectories {
    param(
        [string]$DestDir,
        [bool]$DryRun = $false
    )

    if (-not (Test-Path -Path $DestDir -PathType Container)) {
        Write-Host "  [info] Destination $DestDir does not exist yet — nothing to clean."
        return
    }

    Write-Host "Cleaning previously installed sdlc-* artifacts in $DestDir..."
    $items = @(Get-ChildItem -Path $DestDir -Directory -Filter "sdlc-*" -ErrorAction SilentlyContinue)
    if ($items.Count -eq 0) {
        Write-Host "  [info] No sdlc-* artifacts to remove."
        return
    }

    foreach ($item in $items) {
        if ($DryRun) {
            Write-Host "  [dry-run] Would remove: $($item.FullName)"
        }
        else {
            Remove-Item -Path $item.FullName -Recurse -Force
            Write-Host "  [ok] Removed: $($item.FullName)"
        }
    }
}
