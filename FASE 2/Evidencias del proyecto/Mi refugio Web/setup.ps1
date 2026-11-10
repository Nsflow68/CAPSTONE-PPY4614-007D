param(
    [switch]$SetupOnly,
    [switch]$CollectStatic,
    [string]$BindHost = "127.0.0.1",
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Write-Step([string]$Message) {
    Write-Host "[setup] $Message"
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $pythonCmd) {
    throw "Python 3.10+ no esta instalado o no se encuentra en PATH."
}

$venvDir = Join-Path $PSScriptRoot ".venv"
$venvPython = Join-Path $venvDir "Scripts\python.exe"

if (-not (Test-Path $venvPython)) {
    Write-Step "Creando entorno virtual en .venv..."
    & $pythonCmd.Source -m venv $venvDir
}

Write-Step "Actualizando pip e instalando dependencias..."
& $venvPython -m pip install --upgrade pip --quiet
& $venvPython -m pip install -r requirements.txt --quiet

$envPath = Join-Path $PSScriptRoot ".env"
$envExamplePath = Join-Path $PSScriptRoot ".env.example"

if (-not (Test-Path $envPath)) {
    Write-Step "Generando .env desde .env.example con SECRET_KEY aleatoria..."
    Copy-Item $envExamplePath $envPath
    $secretKey = & $venvPython -c "import secrets; print(secrets.token_urlsafe(50))"
    $content = [System.IO.File]::ReadAllText($envPath, [System.Text.UTF8Encoding]::new($false))
    $content = $content.Replace("replace-with-secure-random-secret-key", $secretKey.Trim())
    [System.IO.File]::WriteAllText($envPath, $content, [System.Text.UTF8Encoding]::new($false))
}

$mediaDir = Join-Path $PSScriptRoot "media"
if (-not (Test-Path $mediaDir)) {
    New-Item -ItemType Directory -Path $mediaDir | Out-Null
}

Write-Step "Validando configuracion de Django..."
& $venvPython manage.py check

Write-Step "Aplicando migraciones de base de datos..."
& $venvPython manage.py migrate --noinput

if ($CollectStatic) {
    Write-Step "Recolectando archivos estaticos..."
    & $venvPython manage.py collectstatic --noinput --clear | Out-Null
}

if ($SetupOnly) {
    Write-Step "Inicializacion completada (-SetupOnly)."
    exit 0
}

Write-Step "Levantando Mi Refugio Web en http://${BindHost}:${Port} ..."
& $venvPython manage.py runserver "${BindHost}:${Port}"

