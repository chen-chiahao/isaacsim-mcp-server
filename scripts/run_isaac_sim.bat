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

if not exist "%ISAAC_SIM_BAT%" (
  echo Error: Isaac Sim launcher not found at: %ISAAC_SIM_BAT% >&2
  echo Set ISAACSIM_ROOT to your Isaac Sim install directory and try again. >&2
  exit /b 1
)

if not exist "%EXTENSION_TOML%" (
  echo Error: extension manifest not found at: %EXTENSION_TOML% >&2
  echo Run this script from inside the isaacsim-mcp-server checkout. >&2
  exit /b 1
)

echo Repo root: %REPO_ROOT%
echo Isaac Sim: %ISAAC_SIM_BAT%
echo Extension: %EXTENSION_ID%

"%ISAAC_SIM_BAT%" --ext-folder "%REPO_ROOT%" --enable "%EXTENSION_ID%" %*
