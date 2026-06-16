@echo off
setlocal enabledelayedexpansion

set "REPO_ROOT=%~dp0.."
set "PYTHON_BIN=%REPO_ROOT%\.venv\Scripts\python.exe"

cd /d "%REPO_ROOT%"

if not exist "%PYTHON_BIN%" (
  echo Error: Python virtual environment not found at: %PYTHON_BIN% >&2
  echo Please run setup_python_env.bat first. >&2
  exit /b 1
)

"%PYTHON_BIN%" -m mcp dev isaac_mcp\server.py %*
