@echo off
setlocal enabledelayedexpansion

pushd "%~dp0.."
set "REPO_ROOT=%CD%"
popd
set "PYTHON_BIN=%REPO_ROOT%\.venv\Scripts\python.exe"
set "INSTALLED_CLI=%REPO_ROOT%\.venv\Scripts\isaacsim-mcp-server.exe"

if exist "%INSTALLED_CLI%" (
  if "%ISAAC_MCP_PORT%"=="" set "ISAAC_MCP_PORT=8766"
  "%INSTALLED_CLI%" %*
  exit /b
)

if exist "%PYTHON_BIN%" (
  if exist "%REPO_ROOT%\isaac_mcp\server.py" (
    cd /d "%REPO_ROOT%"
    if "%ISAAC_MCP_PORT%"=="" set "ISAAC_MCP_PORT=8766"
    "%PYTHON_BIN%" -m isaac_mcp.server %*
    exit /b
  )
)

echo Error: isaacsim-mcp-server not found. >&2
echo Install via: pip install isaacsim-mcp-server >&2
echo Or run: scripts\setup_python_env.bat >&2
exit /b 1
