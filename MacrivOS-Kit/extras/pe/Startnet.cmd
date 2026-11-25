@echo off
rem ============================================================
rem  MacrivOS 1.0 - arranque del entorno (Startnet.cmd)
rem  Este archivo reemplaza al original dentro del boot.wim.
rem ============================================================
wpeinit

rem -- localizar la unidad USB que contiene MacrivOS
set MEDIA=
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  if exist %%D:\MacrivOS\inicio.hta set MEDIA=%%D:
)

rem -- abrir el escritorio del investigador
if defined MEDIA (
  start "" mshta.exe "%MEDIA%\MacrivOS\inicio.hta"
) else (
  echo No se encontro MacrivOS en ninguna unidad.
  echo Unidad del sistema: X:  Comandos disponibles: wpeinit, dism, diskpart
  cmd.exe
)
