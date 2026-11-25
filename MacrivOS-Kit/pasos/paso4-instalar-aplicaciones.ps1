# MacrivOS 1.0 - Paso 4: instalacion de aplicaciones portables en el medio
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

$Desc = Join-Path $RaizTrabajo 'Descargas'
$M    = Join-Path $RaizTrabajo 'PE\media'
$Apps = Join-Path $M 'MacrivOS\Apps'
New-Item -ItemType Directory -Force -Path $Apps | Out-Null
$tmp  = Join-Path $RaizTrabajo 'Temp'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

Write-Host "  [1/5] LibreOffice Portable (sustituto libre de Office 2016)..."
$paf = Join-Path $Desc 'LibreOfficePortable.paf.exe'
if ($RaizTrabajo -match ' ') { throw "La carpeta de trabajo contiene espacios; LibreOffice Portable la necesita sin espacios." }
Start-Process -Wait -FilePath $paf -ArgumentList '/S', ('/D=' + (Join-Path $Apps 'LibreOfficePortable'))
if (-not (Test-Path (Join-Path $Apps 'LibreOfficePortable\LibreOfficePortable.exe'))) {
    throw "El instalador de LibreOffice Portable no dejo el lanzador esperado. Instale manualmente: $paf (con /S) hacia $Apps\LibreOfficePortable"
}
Write-Host "      OK"

Write-Host "  [2/5] Zotero (gestor de referencias)..."
if ($Arquitectura -eq 'amd64' -and (Test-Path (Join-Path $Desc 'Zotero-win64.zip'))) {
    $zTmp = Join-Path $tmp 'zotero'
    Remove-Item -Recurse -Force $zTmp -ErrorAction SilentlyContinue
    Expand-Archive -Path (Join-Path $Desc 'Zotero-win64.zip') -DestinationPath $zTmp -Force
    $exe = Get-ChildItem $zTmp -Recurse -Filter 'zotero.exe' | Select-Object -First 1
    if ($exe) {
        Move-Item $exe.Directory.FullName (Join-Path $Apps 'Zotero') -Force
        Write-Host "      OK"
    } else { Write-Host "      [AVISO] zotero.exe no encontrado en el ZIP; se omite." }
} else {
    Write-Host "      [AVISO] Zotero no disponible para esta arquitectura; se omite."
}

Write-Host "  [3/5] Notepad++ y SumatraPDF..."
if (Test-Path (Join-Path $Desc 'NotepadPP-portable.zip')) {
    Expand-Archive (Join-Path $Desc 'NotepadPP-portable.zip') (Join-Path $Apps 'Notepad++') -Force
    Write-Host "      Notepad++ OK"
}
if (Test-Path (Join-Path $Desc 'SumatraPDF-64.zip')) {
    Expand-Archive (Join-Path $Desc 'SumatraPDF-64.zip') (Join-Path $Apps 'Sumatra') -Force
    $exe = Get-ChildItem (Join-Path $Apps 'Sumatra') -Recurse -Filter 'SumatraPDF.exe' | Select-Object -First 1
    if ($exe -and $exe.Directory.Name -ne 'Sumatra') {
        Move-Item $exe.Directory.FullName (Join-Path $Apps 'Sumatra') -Force
    }
    Write-Host "      SumatraPDF OK"
}

Write-Host "  [4/5] 7-Zip consola (para descomprimir en el PE)..."
$sz = Join-Path $Apps '7-Zip'
New-Item -ItemType Directory -Force -Path $sz | Out-Null
Copy-Item (Join-Path $Desc '7zr.exe') (Join-Path $sz '7zr.exe') -Force
if (Test-Path (Join-Path $Desc '7z-extra.7z')) {
    $sTmp = Join-Path $tmp '7zip'
    Remove-Item -Recurse -Force $sTmp -ErrorAction SilentlyContinue
    $proc = Start-Process -Wait -FilePath (Join-Path $Desc '7zr.exe') -ArgumentList 'x','-y','-o'+$sTmp,(Join-Path $Desc '7z-extra.7z') -PassThru
    if ($proc.ExitCode -eq 0) {
        $sub = if ($Arquitectura -eq 'amd64') { 'x64' } else { 'x86' }
        foreach ($f in @('7z.exe','7z.dll')) {
            $hallado = Get-ChildItem $sTmp -Recurse -Filter $f | Where-Object { $_.FullName -like "*\$sub*" } | Select-Object -First 1
            if (-not $hallado) { $hallado = Get-ChildItem $sTmp -Recurse -Filter $f | Select-Object -First 1 }
            if ($hallado) { Copy-Item $hallado.FullName (Join-Path $sz $f) -Force }
        }
        Write-Host "      7-Zip OK"
    }
}

Write-Host "  [5/5] Complemento Better BibTeX para Zotero..."
if (Test-Path (Join-Path $Desc 'BetterBibTeX.xpi')) {
    $zex = Join-Path $Apps 'Zotero-Extras'
    New-Item -ItemType Directory -Force -Path $zex | Out-Null
    Copy-Item (Join-Path $Desc 'BetterBibTeX.xpi') $zex -Force
    Write-Host "      OK (se instala desde Zotero: Herramientas > Complementos)"
}
if ($UsarZimOffline -and (Test-Path (Join-Path $Desc 'biblioteca-offline.zim'))) {
    $bo = Join-Path $M 'MacrivOS\Biblioteca-Offline'
    New-Item -ItemType Directory -Force -Path $bo | Out-Null
    Copy-Item (Join-Path $Desc 'biblioteca-offline.zim') $bo -Force
    Write-Host "      Biblioteca ZIM copiada"
}

Write-Host ""
Get-ChildItem $Apps -Directory | ForEach-Object {
    $sz2 = (Get-ChildItem $_.FullName -Recurse -File | Measure-Object Length -Sum).Sum
    Write-Host ("      " + $_.Name + ": " + [math]::Round($sz2/1MB,1) + " MB")
}
Write-Host "  PASO 4 COMPLETADO"
exit 0
