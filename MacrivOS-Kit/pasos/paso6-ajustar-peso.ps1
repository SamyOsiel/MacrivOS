# MacrivOS 1.0 - Paso 6: ajuste al peso objetivo (3,50 GB) e informe
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

$M       = Join-Path $RaizTrabajo 'PE\media'
$MK      = Join-Path $M 'MacrivOS'
$Reserva = Join-Path $MK 'ESPACIO-RESERVADO-TRABAJO.bin'
$ObjetivoBytes = [int64]($PesoObjetivoGB * 1000000000)   # GB decimales

# --- peso actual por componente
$pesoReserva = (Get-Item $Reserva -ErrorAction SilentlyContinue).Length
if (-not $pesoReserva) { $pesoReserva = 0 }
$pesoWim   = (Get-Item (Join-Path $M 'sources\boot.wim')).Length
$pesoApps  = (Get-ChildItem (Join-Path $MK 'Apps') -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
if (-not $pesoApps) { $pesoApps = 0 }
$pesoResto = (Get-ChildItem $M -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$pesoResto = $pesoResto - $pesoWim - $pesoApps - $pesoReserva   # plantillas, biblioteca, arranque, etc.

$pesoActual = (Get-ChildItem $M -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$delta = $ObjetivoBytes - $pesoActual

Write-Host ("  Peso actual del medio:  " + [math]::Round($pesoActual/1MB,1) + " MB")
Write-Host ("  Objetivo:               " + $PesoObjetivoGB.ToString('0.00') + " GB (" + $ObjetivoBytes + " bytes)")

if ($delta -gt 104857600) {
    Write-Host ("  [+] Creando reserva de trabajo: " + [math]::Round($delta/1MB,1) + " MB ...")
    # Archivo de ceros que completa el peso pedido. Tras grabar el USB,
    # se puede borrar para usar ese espacio en el propio USB.
    if (Test-Path $Reserva) { Remove-Item $Reserva -Force }
    fsutil file createnew $Reserva $delta | Out-Null
    Write-Host "      OK"
} elseif ($delta -gt 0) {
    Write-Host "  [INFO] Diferencia menor a 100 MB; no se crea reserva."
} else {
    Write-Host ("  [AVISO] El contenido ya supera el objetivo en " + [math]::Round(-$delta/1MB,1) +
                 " MB. Se omite la reserva; el ISO quedara algo mayor.")
}

# --- informe legible
$pesoFinal = (Get-ChildItem $M -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$lineas = @(
  'INFORME DE PESO DE MACRIVOS',
  '===========================',
  ('Objetivo solicitado            : ' + $PesoObjetivoGB.ToString('0.00') + ' GB'),
  ('Nucleo WinPE (boot.wim)        : ' + [math]::Round($pesoWim/1MB,1) + ' MB'),
  ('Aplicaciones (Apps)            : ' + [math]::Round($pesoApps/1MB,1) + ' MB'),
  ('Plantillas, biblioteca y resto : ' + [math]::Round($pesoResto/1MB,1) + ' MB'),
  ('Espacio reservado de trabajo   : ' + [math]::Round($pesoReserva/1MB,1) + ' MB'),
  ('PESO TOTAL ESTIMADO DEL ISO    : ' + [math]::Round($pesoFinal/1GB,2) + ' GB'),
  '',
  'El archivo ESPACIO-RESERVADO-TRABAJO.bin completa el peso pedido',
  '(3,50 GB). Una vez grabado el USB puede borrarse para usar ese',
  'espacio libre como zona de trabajo dentro del propio USB.'
)
Set-Content -Path (Join-Path $KitRaiz 'salida\Informe-Peso.txt') -Value $lineas -Encoding UTF8
$lineas | ForEach-Object { Write-Host ("  " + $_) }
Write-Host "  PASO 6 COMPLETADO"
exit 0
