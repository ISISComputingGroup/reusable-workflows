@echo off
IF "%1"=="" GOTO HAVE_0_ARGS

FOR /F "delims=" %%i IN ('git rev-parse --git-dir') DO set REUSABLE_WF_GITDIR=%%i
if exist "%REUSABLE_WF_GITDIR%/../ruff.toml" (
  set "REUSABLE_WF_RUFF_CONFIG=%REUSABLE_WF_GITDIR%/../ruff.toml"
) else (
  set "REUSABLE_WF_RUFF_CONFIG=%~dp0\..\ruff.toml"
)
c:\instrument\apps\Python3\scripts\ruff %* --config="%REUSABLE_WF_RUFF_CONFIG%"
exit /b %errorlevel%

:HAVE_0_ARGS
echo "Usage: either 'r check' or 'r format'"
