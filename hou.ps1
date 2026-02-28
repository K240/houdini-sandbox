param(
    [Parameter(Position = 0)]
    [string]$Major,

    [Parameter(Position = 1)]
    [string]$Minor,

    [Parameter(Position = 2)]
    [string]$Patch,

    [Parameter(Position = 3)]
    [string]$PythonVersion
)

function Import-DotEnv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '' -or $trimmed.StartsWith('#')) {
            continue
        }

        if ($trimmed -notmatch '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
            continue
        }

        $name = $matches[1]
        $value = $matches[2].Trim()
        if ($value.Length -ge 2) {
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        Set-Item -Path "Env:$name" -Value $value
    }
}

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Import-DotEnv -Path (Join-Path $scriptDir ".env")

$hasAnyArg = $PSBoundParameters.ContainsKey('Major') -or
    $PSBoundParameters.ContainsKey('Minor') -or
    $PSBoundParameters.ContainsKey('Patch') -or
    $PSBoundParameters.ContainsKey('PythonVersion')

if ($hasAnyArg) {
    if (-not (
        $PSBoundParameters.ContainsKey('Major') -and
        $PSBoundParameters.ContainsKey('Minor') -and
        $PSBoundParameters.ContainsKey('Patch') -and
        $PSBoundParameters.ContainsKey('PythonVersion')
    )) {
        throw "Use either all 4 arguments (<Major> <Minor> <Patch> <PythonVersion>) or no arguments."
    }

    $resolvedMajor = $Major
    $resolvedMinor = $Minor
    $resolvedPatch = $Patch
    $resolvedPythonVersion = $PythonVersion
}
else {
    $houdiniVersion = if ($env:HOUDINI_VERSION) { $env:HOUDINI_VERSION } else { $env:HOU_FULLVER }
    $resolvedPythonVersion = if ($env:PYTHON_VERSION) { $env:PYTHON_VERSION } else { $env:PY_VERSION }

    if ([string]::IsNullOrWhiteSpace($houdiniVersion) -or [string]::IsNullOrWhiteSpace($resolvedPythonVersion)) {
        throw "When no arguments are provided, .env must define HOUDINI_VERSION and PYTHON_VERSION."
    }

    if ($houdiniVersion -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        throw "HOUDINI_VERSION must be in major.minor.patch format (e.g. 22.0.631)"
    }

    $houdiniParts = $houdiniVersion -split '\.'
    $resolvedMajor = $houdiniParts[0]
    $resolvedMinor = $houdiniParts[1]
    $resolvedPatch = $houdiniParts[2]
}

if ($resolvedPythonVersion -notmatch '^3\.[0-9]+$') {
    throw "PythonVersion must be in major.minor format (e.g. 3.11 or 3.13)"
}

$env:HSITE = $scriptDir
$env:HOU_VER = "$resolvedMajor.$resolvedMinor"
$env:HOU_FULLVER = "$resolvedMajor.$resolvedMinor.$resolvedPatch"
$env:PY_VERSION = "$resolvedPythonVersion"
$env:PY_UV_VERSION = "python$resolvedPythonVersion"

uv sync --directory "$($env:HSITE)/uv/$($env:PY_UV_VERSION)"

$houdiniExe = "c:\Program Files\Side Effects Software\Houdini $($env:HOU_FULLVER)\bin\houdini.exe"
Start-Process -FilePath $houdiniExe
