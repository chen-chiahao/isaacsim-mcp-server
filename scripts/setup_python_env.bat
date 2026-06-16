@echo off
setlocal enabledelayedexpansion

set "REPO_ROOT=%~dp0.."
set UV_SYSTEM_CERTS=1
if "%PYTHON_SPEC%"=="" set "PYTHON_SPEC=python"

cd /d "%REPO_ROOT%"

if not exist ".venv" (
  echo Creating virtual environment with: %PYTHON_SPEC%
  uv venv --python "%PYTHON_SPEC%"
) else (
  echo Using existing virtual environment at: %REPO_ROOT%\.venv
)

echo Installing isaacsim-mcp-server and dependencies
uv pip install --python .venv\Scripts\python.exe -e "."

echo.
echo Done.
echo Activate with: .venv\Scripts\activate
