@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  sauvegarde.bat
rem  Usage :
rem    - double-clic : sauvegarde le dossier courant du script
rem    - glisser-deposer un dossier de projet sur l'icone du .bat
rem    - en ligne de commande : sauvegarde.bat "C:\chemin\projet"
rem  Cree une archive tar --zstd (fallback tar.gz si zstd absent)
rem  dans %USERPROFILE%\Desktop\Sauvegardes, prete a etre glissee
rem  vers un drive (OneDrive/Google Drive) et/ou une cle USB.
rem ============================================================

if "%~1"=="" (
    set "SOURCE=%CD%"
) else (
    set "SOURCE=%~1"
)

if not exist "%SOURCE%" (
    echo Dossier introuvable : %SOURCE%
    pause
    exit /b 1
)

for %%F in ("%SOURCE%") do (
    set "PARENT=%%~dpF"
    set "PROJET=%%~nxF"
)

set "DESTDIR=%USERPROFILE%\Desktop\Sauvegardes"
if not exist "%DESTDIR%" mkdir "%DESTDIR%"

rem Horodatage fiable, independant de la locale (via PowerShell)
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "HORODATAGE=%%I"

set "ARCHIVE=%DESTDIR%\%USERNAME%_%PROJET%_%HORODATAGE%.tar.zst"

echo Sauvegarde de "%SOURCE%" vers :
echo   %ARCHIVE%
echo.

tar --zstd -cf "%ARCHIVE%" -C "%PARENT%" "%PROJET%" 2>nul

if not exist "%ARCHIVE%" (
    echo zstd indisponible sur ce poste, utilisation de gzip a la place.
    set "ARCHIVE=%DESTDIR%\%USERNAME%_%PROJET%_%HORODATAGE%.tar.gz"
    tar -czf "%ARCHIVE%" -C "%PARENT%" "%PROJET%"
)

if exist "%ARCHIVE%" (
    echo.
    echo Archive creee avec succes :
    echo   %ARCHIVE%
    echo.
    echo Glissez ce fichier dans votre navigateur ^(OneDrive / Google Drive^)
    echo et/ou copiez-le sur votre cle USB.
    explorer /select,"%ARCHIVE%"
) else (
    echo.
    echo ERREUR lors de la creation de l'archive.
)

pause
