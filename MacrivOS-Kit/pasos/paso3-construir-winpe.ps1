# MacrivOS 1.0 - Paso 3: construccion del nucleo WinPE (amd64, espanol)
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

$ADK      = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\Assessment and Deployment Kit'
$CopypeDir= Join-Path $ADK "Windows Preinstallation Environment\copype\$Arquitectura"
$Oscdimg  = Join-Path $ADK 'Oscdimg\oscdimg.exe'
$OCs      = Join-Path $ADK "Windows Preinstallation Environment\$Arquitectura\WinPE_OCs"
$PE       = Join-Path $RaizTrabajo 'PE'
$Montaje  = Join-Path $PE 'mount'

function DisM([string[]]$args) { & dism @args | Out-Null; if ($LASTEXITCODE -ne 0) { throw "dism fallo con codigo $LASTEXITCODE" } }

Write-Host "  [1/6] Preparando la carpeta PE (se rehace desde cero)..."
if (Test-Path (Join-Path $PE 'mount')) { & dism /Unmount-Wim /MountDir:$Montaje /Discard 2>$null | Out-Null }
Remove-Item -Recurse -Force $PE -ErrorAction SilentlyContinue
Push-Location $CopypeDir
try { cmd /c "copype.cmd $Arquitectura `"$PE`"" | Out-Null; if ($LASTEXITCODE -ne 0) { throw "copype fallo" } }
finally { Pop-Location }

Write-Host "  [2/6] Montando boot.wim (imagen 1)..."
DisM @('/Mount-Wim','/WimFile:'+(Join-Path $PE 'media\sources\boot.wim'),'/Index:1','/MountDir:'+$Montaje)

try {
    Write-Host "  [3/6] Agregando paquetes del PE (WMI, Scripting, HTA, PowerShell)..."
    $paquetes = @('WinPE-WMI.cab','WinPE-Scripting.cab','WinPE-HTA.cab','WinPE-PowerShell.cab')
    foreach ($p in $paquetes) {
        $cab = Join-Path $OCs $p
        if (Test-Path $cab) {
            DisM @('/Image:'+$Montaje,'/Add-Package','/PackagePath:'+$cab)
            $es = Join-Path $OCs "$IdiomaPE\" + ($p -replace '\.cab$', "_$IdiomaPE.cab")
            if (Test-Path $es) { DisM @('/Image:'+$Montaje,'/Add-Package','/PackagePath:'+$es) }
        } else {
            Write-Host ("      [AVISO] No existe " + $p + " en este ADK; se omite.")
        }
    }

    Write-Host "  [4/6] Idioma $IdiomaPE del sistema y teclado..."
    $lp = Join-Path $OCs "$IdiomaPE\lp.cab"
    if (Test-Path $lp) {
        DisM @('/Image:'+$Montaje,'/Add-Package','/PackagePath:'+$lp)
        DisM @('/Image:'+$Montaje,'/Set-AllIntl:'+ $IdiomaPE)
        DisM @('/Image:'+$Montaje,'/Set-SysLocale:'+ $IdiomaPE)
        DisM @('/Image:'+$Montaje,'/Set-UserLocale:'+ $IdiomaPE)
        DisM @('/Image:'+$Montaje,'/Set-InputLocale:0c0a:00000c0a')
    } else {
        Write-Host "      [AVISO] Paquete de idioma $IdiomaPE no encontrado; el PE quedara en ingles."
    }

    Write-Host "  [5/6] Drivers opcionales, arranque y fondo de MacrivOS..."
    $drv = Join-Path $KitRaiz 'Drivers'
    if (Test-Path $drv) {
        $infs = @(Get-ChildItem $drv -Filter *.inf -Recurse)
        if ($infs.Count -gt 0) {
            DisM @('/Image:'+$Montaje,'/Add-Driver','/Driver:'+$drv,'/Recurse')
            Write-Host ("      Integrados " + $infs.Count + " drivers")
        }
    }
    Copy-Item "$KitRaiz\extras\pe\Startnet.cmd" (Join-Path $Montaje 'Windows\System32\Startnet.cmd') -Force
    Copy-Item "$KitRaiz\extras\pe\winpe.jpg"    (Join-Path $Montaje 'Windows\System32\winpe.jpg')    -Force
}
finally {
    Write-Host "  [6/6] Guardando y desmontando la imagen..."
    DisM @('/Unmount-Wim','/MountDir:'+$Montaje,'/Commit')
}

$boot = Get-Item (Join-Path $PE 'media\sources\boot.wim')
Write-Host ("  Nucleo boot.wim: " + [math]::Round($boot.Length/1MB,1) + " MB (aceptable para 2 GB de RAM)")
Write-Host "  PASO 3 COMPLETADO"
exit 0
