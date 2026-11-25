# ============================================================
#  MacrivOS 1.0 - Configuracion del kit de construccion
#  Edite este archivo solo si sabe lo que hace.
# ============================================================

# --- Peso objetivo del ISO (GB decimales). El kit crea un archivo
#     de reserva para completar exactamente este peso. 3.50 = pedido del usuario.
$PesoObjetivoGB = 3.50

# --- Arquitectura del entorno PE.
#     'amd64' = 64 bits (OBLIGATORIO para arrancar en el Chromebook 3 con
#     firmware UEFI Full ROM de MrChromebox: el firmware es x86_64 exclusivo
#     y rechaza medios de 32 bits y arranque BIOS/CSM).
#     'x86'   = 32 bits, SOLO para PC antiguos con BIOS clasica o UEFI de
#     32 bits. En ese caso Zotero no esta disponible (ya no hay compilacion
#     de 32 bits para Windows) y LibreOffice se usa en su variante 25.8.5.
$Arquitectura = 'amd64'

# --- Idioma del entorno PE (paquete de idioma incluido en el ADK).
$IdiomaPE = 'es-ES'

# --- Carpeta raiz de construccion (sin espacios).
$RaizTrabajo = 'C:\MacrivOS-build'

# --- Descargas directas (URL verificadas en noviembre de 2026).
$URLLibreOfficeAmd64 = 'https://download.documentfoundation.org/libreoffice/portable/26.2.4/LibreOfficePortable_26.2.4_MultilingualStandard.paf.exe'
$URLLibreOfficeX86   = 'https://download.documentfoundation.org/libreoffice/portable/25.8.5/LibreOfficePortable_25.8.5_MultilingualStandard.paf.exe'

# Zotero 10: endpoint oficial que entrega el ZIP de 64 bits mas reciente.
$URLZoteroZip = 'https://www.zotero.org/download/client/dl?channel=release&platform=win-x64-zip'

# 7-Zip: binario de consola estable (siempre presente en 7-zip.org).
$URL7zr = 'https://www.7-zip.org/a/7zr.exe'

# --- Resolucion de "ultima version" mediante la API publica de GitHub.
#     El paso 2 consulta la API y, si falla, usa los enlaces fijos de abajo.
$GHNotepadPP = 'https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest'
$GHSumatra   = 'https://api.github.com/repos/sumatrapdfreader/sumatrapdf/releases/latest'
$GHBetterBibTeX = 'https://api.github.com/repos/retorquere/better-bibtex/releases/latest'

$URLNotepadPPFijo = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.9.1/npp.8.9.9.1.portable.x64.zip'
$URLSumatraFijo   = 'https://github.com/sumatrapdfreader/sumatrapdf/releases/download/3.6.1rel/SumatraPDF-3.6.1-64.zip'
$URLBBTFijo       = ''   # sin enlace fijo: si la API falla, el modulo se omite

# --- Descarga OPCIONAL de bibliotecas fuera de linea (KiwiX + ZIM de
#     Wikipedia en espanol, licencia CC BY-SA). Desactivada por defecto;
#     si la activa, escriba la URL completa del archivo .zim que prefiera
#     desde https://download.kiwix.org/zim/wikipedia/ y sera copiada a
#     MacrivOS\Biblioteca-Offline.
$UsarZimOffline = $false
$URLZimOffline  = ''
