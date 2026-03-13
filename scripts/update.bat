@echo off
REM GrabaKar — Update: pull latest for all repos (Windows)
setlocal enabledelayedexpansion

set REPOS_DIR=%~dp0..\repos

if not exist "%REPOS_DIR%" (
    echo Error: repos\ directory not found. Run setup.bat first.
    exit /b 1
)

for /d %%d in ("%REPOS_DIR%\*") do (
    if exist "%%d\.git" (
        echo Updating %%~nxd...
        pushd "%%d"
        git pull --ff-only
        popd
    )
)

echo.
echo All repos updated.
