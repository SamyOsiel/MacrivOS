# MacrivOS 1.0 - Paso 1: verificacion del entorno de construccion
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot          # ...\MacrivOS-Kit
. "$KitRaiz\config\variables.ps1"

New-Item -ItemType Directory -Force -Path "$KitRaiz\salida" | Out-Null
Start-Transcript -Path "$KitRaiz\salida\registro.txt" -Append | Out-Null
function Log($m) { Write-Host ("  " + $m) }

try {
    # --- administrador
    $adm = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $adm) { throw "Ejecute CONSTRUIR.cmd con permisos de administrador." }
    Log "[OK] Permisos de administrador"

    # --- Windows 64 bits
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        throw "Este kit requiere Windows de 64 bits (el nucleo amd64 no se puede construir desde un Windows de 32 bits)."
    }
    Log "[OK] Windows de 64 bits"

    # --- espacio libre
    $c = Get-PSDrive C
    $libreGB = [math]::Round($c.Free / 1GB, 1)
    if ($libreGB -lt 15) { throw "Se necesitan al menos 15 GB libres en C: (hay $libreGB GB)." }
    Log "[OK] Espacio libre en C: $libreGB GB"

    # --- rutas del Windows ADK
    $ADK = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\Assessment and Deployment Kit'
    $Copype = Join-Path $ADK "Windows Preinstallation Environment\copype\$Arquitectura\copype.cmd"
    $Oscdimg = Join-Path $ADK 'Oscdimg\oscdimg.exe'
    $OCs = Join-Path $ADK "Windows Preinstallation Environment\$Arquitectura\WinPE_OCs"
    $falta = @()
    foreach ($p in @($Copype, $Oscdimg, $OCs)) { if (-not (Test-Path $p)) { $falta += $p } }
    if ($falta.Count -gt 0) {
        Write-Host ""
        Write-Host "  [FALTA] No se encontraron componentes del Windows ADK:"
        $falta | ForEach-Object { Write-Host ("      - " + $_) }
        Write-Host ""
        Write-Host "  Instale (gratuito, ~2 GB):"
        Write-Host "   1. Windows ADK:  https://learn.microsoft.com/windows-hardware/get-started/adk-install"
        Write-Host "      ( marque solo 'Deployment Tools' )"
        Write-Host "   2. Complemento WinPE para el ADK (mismo numero de version)."
        Write-Host "   3. Vuelva a ejecutar CONSTRUIR.cmd"
        throw "Falta el Windows ADK o el complemento WinPE."
    }
    Log "[OK] Windows ADK + complemento WinPE detectados"

    # --- carpeta Drivers opcional
    $drv = Join-Path $KitRaiz 'Drivers'
    if (Test-Path $drv) {
        $n = @(Get-ChildItem $drv -Filter *.inf -Recurse).Count
        if ($n -gt 0) { Log "[INFO] Se integraran $n drivers desde la carpeta Drivers" }
    }

    # --- conexion a Internet
    try {
        $r = Invoke-WebRequest -UseBasicParsing -Method Head -TimeoutSec 20 -Uri 'https://download.documentfoundation.org/'
        Log "[OK] Conexion a Internet"
    } catch {
        throw "No hay conexion a Internet (o download.documentfoundation.org esta bloqueado). Las descargas son imprescindibles."
    }

    # --- preparar carpeta de trabajo
    New-Item -ItemType Directory -Force -Path "$RaizTrabajo\Descargas" | Out-Null
    New-Item -ItemType Directory -Force -Path "$RaizTrabajo\Media\MacrivOS\Apps" | Out-Null
    Log "[OK] Carpeta de trabajo: $RaizTrabajo"

    Write-Host ""
    Write-Host ("  Configuracion: arquitectura=$Arquitectura  idioma=$IdiomaPE  objetivo=$PesoObjetivoGB GB")
    Write-Host "  PASO 1 COMPLETADO"
    exit 0
}
catch {
    Write-Host ""
    Write-Host ("  ERROR EN PASO 1: " + $_.Exception.Message)
    Stop-Transcript | Out-Null
    exit 1
}
