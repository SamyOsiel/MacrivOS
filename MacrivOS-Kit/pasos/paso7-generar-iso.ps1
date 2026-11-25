# MacrivOS 1.0 - Paso 7: generacion del ISO arrancable (BIOS + UEFI x64)
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

$ADK     = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\Assessment and Deployment Kit'
$Oscdimg = Join-Path $ADK 'Oscdimg\oscdimg.exe'
$ETFS    = Join-Path $ADK 'Oscdimg\etfsboot.com'
$EFISYS  = Join-Path $ADK 'Oscdimg\efisys.bin'
$M       = Join-Path $RaizTrabajo 'PE\media'
$Salida  = Join-Path $KitRaiz 'salida\MacrivOS.iso'

New-Item -ItemType Directory -Force -Path (Join-Path $KitRaiz 'salida') | Out-Null
if (Test-Path $Salida) { Remove-Item $Salida -Force }

Write-Host "  Empaquetando con oscdimg (arranque BIOS + UEFI de 64 bits)..."
# -bootdata:2#p0,e,b<etfsboot.com>#pEF,e,b<efisys.bin> -> arranque BIOS y UEFI x64
# -u2 -udfver102 -> sistema de archivos UDF en el ISO
# -o -> optimiza archivos duplicados;  -m -> ignora el limite de 4 GB
$bootdata = '2#p0,e,b' + $ETFS + '#pEF,e,b' + $EFISYS
$argsIso = @('-m','-o','-u2','-udfver102','-lMACRIVOS', ('-bootdata:' + $bootdata), $M, $Salida)
$proc = Start-Process -Wait -FilePath $Oscdimg `
        -ArgumentList $argsIso `
        -PassThru -RedirectStandardOutput (Join-Path $KitRaiz 'salida\oscdimg.log')

if ($proc.ExitCode -ne 0 -or -not (Test-Path $Salida)) {
    Get-Content (Join-Path $KitRaiz 'salida\oscdimg.log') -Tail 20 | ForEach-Object { Write-Host ("      " + $_) }
    throw "oscdimg fallo (codigo $($proc.ExitCode)). Revise salida\oscdimg.log"
}

$iso = Get-Item $Salida
Write-Host ("  ISO generado: " + $iso.FullName + "  (" + [math]::Round($iso.Length/1GB,2) + " GB)")

Set-Content -Path (Join-Path $KitRaiz 'salida\GRABAR-USB.txt') -Value @'
COMO GRABAR MacrivOS.iso EN UN USB
==================================

Opcion A - Rufus (recomendada, gratuito)
  1. Conecte un USB de 8 GB o mas (se borrara todo su contenido).
  2. Abra Rufus: https://rufus.ie
  3. Seleccione el USB, y en "Selección de arranque" elija
     salida\MacrivOS.iso. Esquema de particion: GPT, sistema destino:
     UEFI (no CSM). Pulse EMPEZAR y espere.

Opcion B - desde el propio kit (formatea el USB)
  En PowerShell como administrador, desde la carpeta PE del ADK:
    cd "$env:ProgramFiles(x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
    MakeWinPEMedia /ISO "C:\MacrivOS-build\PE" X:
  (sustituya X: por la letra de su USB; borra TODO el USB).

Para el Chromebook 3 use siempre GPT + UEFI. El arranque se elige
pulsando ESC en el mensaje "Boot Menu" del firmware MrChromebox.
'@ -Encoding UTF8

Write-Host "  PASO 7 COMPLETADO - vea salida\GRABAR-USB.txt"
exit 0
