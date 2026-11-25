# MacrivOS 1.0 - Paso 2: descarga de las aplicaciones libres
$ErrorActionPreference = 'Stop'
$KitRaiz = Split-Path -Parent $PSScriptRoot
. "$KitRaiz\config\variables.ps1"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Desc = Join-Path $RaizTrabajo 'Descargas'
$UA = 'MacrivOS-Kit/1.0 (+personal use)'

function Descargar($url, $dest) {
    if (Test-Path $dest) {
        $t = (Get-Item $dest).Length
        if ($t -gt 1000000) { Write-Host ("  [SALTAR] " + (Split-Path $dest -Leaf) + " ya descargado (" + [math]::Round($t/1MB,1) + " MB)"); return }
    }
    Write-Host ("  [DESCARGAR] " + (Split-Path $dest -Leaf) + " ...")
    Invoke-WebRequest -UseBasicParsing -TimeoutSec 900 -Uri $url -OutFile $dest -UserAgent $UA
    Write-Host ("      " + [math]::Round((Get-Item $dest).Length/1MB,1) + " MB  OK")
}

function UltimoAssetGitHub($apiUrl, $patron) {
    # Devuelve la URL del asset que coincide con el patron; $null si falla.
    # En GitHub Actions se usa el token interno para evitar el limite de peticiones.
    try {
        $cabeceras = @{}
        if ($env:GITHUB_TOKEN) { $cabeceras['Authorization'] = "Bearer $env:GITHUB_TOKEN" }
        $rel = Invoke-RestMethod -Uri $apiUrl -UserAgent $UA -TimeoutSec 60 -Headers $cabeceras
        $a = $rel.assets | Where-Object { $_.name -like $patron } | Select-Object -First 1
        if ($a) { return $a.browser_download_url }
    } catch { Write-Host "  [AVISO] API de GitHub no disponible para: $apiUrl" }
    return $null
}

# --- LibreOffice Portable (sustituto libre de Office, incluye espanol)
if ($Arquitectura -eq 'amd64') { $urlLO = $URLLibreOfficeAmd64 } else { $urlLO = $URLLibreOfficeX86 }
Descargar $urlLO "$Desc\LibreOfficePortable.paf.exe"

# --- Zotero (solo amd64: no existe compilacion de 32 bits para Windows)
if ($Arquitectura -eq 'amd64') {
    Descargar $URLZoteroZip "$Desc\Zotero-win64.zip"
} else {
    Write-Host "  [AVISO] Arquitectura x86: Zotero no esta disponible y se omitira."
}

# --- Notepad++ portable
if ($Arquitectura -eq 'amd64') { $patNPP = '*portable.x64.zip' } else { $patNPP = '*portable.zip' }
$u = UltimoAssetGitHub $GHNotepadPP $patNPP
if (-not $u) { $u = $URLNotepadPPFijo }
Descargar $u "$Desc\NotepadPP-portable.zip"

# --- SumatraPDF portable (lector PDF)
if ($Arquitectura -eq 'amd64') {
    $u = UltimoAssetGitHub $GHSumatra 'SumatraPDF-*-64.zip'
    if (-not $u) { $u = $URLSumatraFijo }
    if ($u) { Descargar $u "$Desc\SumatraPDF-64.zip" }
}

# --- 7-Zip: consola 7zr + paquete extra (para descomprimir dentro del PE)
Descargar $URL7zr "$Desc\7zr.exe"
try {
    $lista = Invoke-WebRequest -UseBasicParsing -TimeoutSec 60 -Uri 'https://www.7-zip.org/a/' -UserAgent $UA
    if ($lista.Content -match '7z(\d{4})-extra\.7z') {
        Descargar "https://www.7-zip.org/a/7z$($Matches[1])-extra.7z" "$Desc\7z-extra.7z"
    }
} catch { Write-Host "  [AVISO] No se pudo leer el catalogo de 7-zip.org: $($_.Exception.Message)" }

# --- Better BibTeX (complemento opcional de Zotero)
$u = UltimoAssetGitHub $GHBetterBibTeX '*.xpi'
if (-not $u) { $u = $URLBBTFijo }
if ($u) { Descargar $u "$Desc\BetterBibTeX.xpi" }
else { Write-Host "  [AVISO] Better BibTeX se omitira (podra instalarse luego desde Zotero)." }

# --- ZIM opcional fuera de linea
if ($UsarZimOffline -and $URLZimOffline) {
    Descargar $URLZimOffline "$Desc\biblioteca-offline.zim"
}

Write-Host ""
Write-Host "  PASO 2 COMPLETADO - Descargas en $Desc"
exit 0
