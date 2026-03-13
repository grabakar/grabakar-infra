@echo off
REM GrabaKar — Setup: clona todos los repos del proyecto (Windows)
setlocal enabledelayedexpansion

set REPO_ORG=grabakar
set REPOS_DIR=%~dp0..\repos

if not exist "%REPOS_DIR%" mkdir "%REPOS_DIR%"

call :clone_or_pull grabakar-backend
call :clone_or_pull grabakar-frontend
call :clone_or_pull grabakar-docs

echo.
echo All repos ready in %REPOS_DIR%\
echo.
echo Next: copy .env.example to .env and run:
echo   docker compose up -d
goto :eof

:clone_or_pull
set name=%1
set dir=%REPOS_DIR%\%name%
if exist "%dir%\.git" (
    echo Updating %name%...
    pushd "%dir%"
    git pull --ff-only
    popd
) else (
    echo Cloning %name%...
    git clone "https://github.com/%REPO_ORG%/%name%.git" "%dir%"
)
goto :eof
