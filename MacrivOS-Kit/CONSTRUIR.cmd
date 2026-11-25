@echo off
rem ============================================================
rem  MacrivOS 1.0 - Constructor del ISO (orquestador)
rem  Ejecute CONSTRUIR.cmd desde una carpeta SIN espacios en la ruta.
rem  Requiere: Windows 10/11 64 bits, Windows ADK + complemento WinPE,
rem  15 GB de espacio libre y conexion a Internet.
rem ============================================================
setlocal enabledelayedexpansion
chcp 65001 >nul
title MacrivOS 1.0 - Constructor del ISO

echo(
echo ============================================================
echo    MacrivOS 1.0 - Entorno de investigacion tipo WinPE
echo    Kit de construccion (genera MacrivOS.iso de 3,50 GB)
echo ============================================================
echo(

rem -- comprobar y elevar a administrador
net session >nul 2>&1
if errorlevel 1 (
    echo [+] Solicitando permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "KIT=%~dp0"
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -File"

echo [PASO 1/7] Verificacion del entorno...
%PS% "%KIT%pasos\paso1-verificar-entorno.ps1" || goto :fallo
echo [PASO 2/7] Descarga de aplicaciones libres...
%PS% "%KIT%pasos\paso2-descargar-aplicaciones.ps1" || goto :fallo
echo [PASO 3/7] Construccion del nucleo WinPE (15-20 min)...
%PS% "%KIT%pasos\paso3-construir-winpe.ps1" || goto :fallo
echo [PASO 4/7] Instalacion de aplicaciones en el medio...
%PS% "%KIT%pasos\paso4-instalar-aplicaciones.ps1" || goto :fallo
echo [PASO 5/7] Escritorio del investigador y contenido...
%PS% "%KIT%pasos\paso5-contenido-investigador.ps1" || goto :fallo
echo [PASO 6/7] Ajuste de peso objetivo (3,50 GB)...
%PS% "%KIT%pasos\paso6-ajustar-peso.ps1" || goto :fallo
echo [PASO 7/7] Generacion del ISO...
%PS% "%KIT%pasos\paso7-generar-iso.ps1" || goto :fallo

echo(
echo ============================================================
echo   PROCESO COMPLETADO
echo   El ISO esta en: %KIT%salida\MacrivOS.iso
echo   Informe de peso: %KIT%salida\Informe-Peso.txt
echo   Siga la Guia-MacrivOS.pdf (seccion 6) para grabar el USB.
echo ============================================================
echo(
pause
exit /b 0

:fallo
echo(
echo ============================================================
echo   ALGUN PASO FALLO. Revise el ultimo mensaje de error.
echo   El registro completo esta en %KIT%salida\registro.txt
echo   (los pasos 3 a 7 pueden reejecutarse tras corregir el
echo   problema; el paso 3 rehace el nucleo PE desde cero).
echo ============================================================
echo(
pause
exit /b 1
