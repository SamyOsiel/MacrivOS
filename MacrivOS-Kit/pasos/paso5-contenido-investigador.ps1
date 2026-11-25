# MacrivOS 1.0 - Paso 5: escritorio del investigador y contenido academico
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

$M  = Join-Path $RaizTrabajo 'PE\media'
$MK = Join-Path $M 'MacrivOS'
New-Item -ItemType Directory -Force -Path $MK | Out-Null

Write-Host "  [1/4] Escritorio del investigador (inicio.hta)..."
Copy-Item "$KitRaiz\extras\dashboard\inicio.hta" (Join-Path $MK 'inicio.hta') -Force

Write-Host "  [2/4] Plantillas APA 7 y biblioteca del investigador..."
New-Item -ItemType Directory -Force -Path (Join-Path $MK 'Plantillas') | Out-Null
Copy-Item "$KitRaiz\extras\plantillas\*" (Join-Path $MK 'Plantillas') -Force
New-Item -ItemType Directory -Force -Path (Join-Path $MK 'Biblioteca') | Out-Null
Copy-Item "$KitRaiz\extras\biblioteca\*" (Join-Path $MK 'Biblioteca') -Force

Write-Host "  [3/4] Carpeta de trabajo (Datos) para guardar en el USB..."
New-Item -ItemType Directory -Force -Path (Join-Path $MK 'Datos\Zotero')  | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $MK 'Datos\Trabajo') | Out-Null
Set-Content -Path (Join-Path $MK 'Datos\Trabajo\GUARDE-AQUI-SUS-ARCHIVOS.txt') -Value @'
Esta carpeta vive en el USB, no en la memoria del equipo.
Todo lo que guarde aqui (capitulos, PDF, biblioteca de Zotero)
se conserva al apagar MacrivOS. Recomendacion: guarde aqui y
copie a otro medio al final de la sesion.
'@ -Encoding UTF8

Write-Host "  [4/4] Licencias y lector rapido de MacrivOS..."
Copy-Item "$KitRaiz\extras\licencias\avisos.txt" (Join-Path $MK 'LICENCIAS.txt') -Force
Set-Content -Path (Join-Path $MK 'LEEME.txt') -Value @'
MACRIVOS 1.0 - ENTORNO DE INVESTIGACION
=======================================

COMO SE USA
El escritorio de MacrivOS se abre solo al arrancar. Desde ahi:
  - Escribir con Writer : editor de textos (abre y guarda .docx)
  - Referencias (Zotero): gestor de bibliografia en APA 7
  - Plantillas APA      : plantillas y matriz de consistencia
  - Biblioteca          : guias rapidas APA 7 y Zotero
  - Leer PDF / Notas    : lector de PDF y editor de notas
  - Guardar trabajo     : carpeta Datos\Trabajo (en el USB)

DONDE GUARDAR
Guarde siempre en MacrivOS\Datos\Trabajo de esta unidad USB.
Lo que quede en la memoria del sistema (X:) se pierde al apagar.

CON 2 GB DE RAM
Abra una aplicacion pesada a la vez (Writer o Zotero). Si el
equipo va lento, cierre la ventana de consola negra de fondo.

AL APAGAR
Cierre Zotero y Writer antes de apagar para no perder cambios.
'@ -Encoding UTF8

Write-Host ""
Write-Host "  Contenido del medio listo:"
Get-ChildItem $MK -Directory | ForEach-Object { Write-Host ("      MacrivOS\" + $_.Name) }
Write-Host "  PASO 5 COMPLETADO"
exit 0
