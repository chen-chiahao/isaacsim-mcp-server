@echo off
setlocal enabledelayedexpansion

pushd "%~dp0.."
set "REPO_ROOT=%CD%"
popd

if "%ISAACSIM_ROOT%"=="" (
  if exist "C:\isaac-sim\isaac-sim.bat" (
    set "ISAACSIM_ROOT=C:\isaac-sim"
  ) else (
    set "ISAACSIM_ROOT=%LOCALAPPDATA%\ov\pkg\isaac-sim-5.1.0"
  )
)
set "ISAAC_SIM_BAT=%ISAACSIM_ROOT%\isaac-sim.bat"
set "EXTENSION_TOML=%REPO_ROOT%\isaac.sim.mcp_extension\config\extension.toml"
set "EXTENSION_ID=isaac.sim.mcp_extension"
set "PYTHON_BIN=%REPO_ROOT%\.venv\Scripts\python.exe"
set "LOG_DIR=%REPO_ROOT%\logs"
if "%ISAAC_MCP_PORT%"=="" set "ISAAC_MCP_PORT=8766"
set /a MCP_MAX_PORT=%ISAAC_MCP_PORT% + 100
set "MCP_WAIT_TIMEOUT=120"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

if not exist "%ISAAC_SIM_BAT%" (
  echo Error: Isaac Sim launcher not found at: %ISAAC_SIM_BAT% >&2
  exit /b 1
)

if not exist "%EXTENSION_TOML%" (
  echo Error: extension manifest not found at: %EXTENSION_TOML% >&2
  exit /b 1
)

:: Find a free port using powershell
for /f "usebackq" %%p in (`powershell -NoProfile -Command "for ($p=%ISAAC_MCP_PORT%; $p -le %MCP_MAX_PORT%; $p++) { $l = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $p); try { $l.Start(); $l.Stop(); $p; break; } catch {} }"`) do (
  set "MCP_PORT=%%p"
)

if "%MCP_PORT%"=="" (
  echo Error: No free port found. >&2
  exit /b 1
)
echo Using port %MCP_PORT% for this instance.

echo Launching Isaac Sim with MCP extension on port %MCP_PORT%...
cd /d "%ISAACSIM_ROOT%"
start "Isaac Sim" isaac-sim.bat --ext-folder "%REPO_ROOT%" --enable "%EXTENSION_ID%" --/exts/isaac.sim.mcp/server.port=%MCP_PORT% %*
cd /d "%REPO_ROOT%"

echo Waiting for MCP extension socket on port %MCP_PORT%...
powershell -NoProfile -Command "$start = Get-Date; while ((Get-Date) -lt $start.AddSeconds(%MCP_WAIT_TIMEOUT%)) { try { $tcpClient = New-Object System.Net.Sockets.TcpClient('localhost', %MCP_PORT%); $tcpClient.Close(); exit 0 } catch { Start-Sleep -Seconds 2 } }; exit 1"
if %ERRORLEVEL% neq 0 (
  echo Error: Timed out waiting for extension socket on port %MCP_PORT%. >&2
  exit /b 1
)

set "INSTALLED_CLI=%REPO_ROOT%\.venv\Scripts\isaacsim-mcp-server.exe"

if not exist "%INSTALLED_CLI%" goto try_python

echo Starting MCP server on port %MCP_PORT%...
set "ISAAC_MCP_PORT=%MCP_PORT%"
start "MCP Server" cmd /c ""%INSTALLED_CLI%" > "%LOG_DIR%\mcp_server_%MCP_PORT%.log" 2>&1"
goto end

:try_python
if not exist "%PYTHON_BIN%" goto no_server

echo Starting MCP server on port %MCP_PORT% (from source)...
cd /d "%REPO_ROOT%"
set "ISAAC_MCP_PORT=%MCP_PORT%"
start "MCP Server" cmd /c ""%PYTHON_BIN%" -m isaac_mcp.server > "%LOG_DIR%\mcp_server_%MCP_PORT%.log" 2>&1"
goto end

:no_server
echo Warning: MCP server not found. Skipping MCP server. >&2

:end
echo Isaac Sim and MCP Server launched.
