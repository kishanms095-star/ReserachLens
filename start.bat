@echo off
setlocal
cd /d "%~dp0"
title ResearchLens
echo ========================================
echo             ResearchLens
echo ========================================
where py >nul 2>nul
if %errorlevel%==0 (
  set "PY=py -3"
) else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo ERROR: Python 3.10 or newer was not found.
    echo Install Python from https://www.python.org/downloads/ and enable Add Python to PATH.
    pause
    exit /b 1
  )
  set "PY=python"
)
%PY% -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)"
if errorlevel 1 (
  echo ERROR: ResearchLens requires Python 3.10 or newer.
  pause
  exit /b 1
)
if not exist ".venv\Scripts\python.exe" (
  echo Creating virtual environment...
  %PY% -m venv .venv
  if errorlevel 1 goto :error
)
call ".venv\Scripts\activate.bat"
echo Installing/checking dependencies...
python -m pip install --upgrade pip
if errorlevel 1 goto :error
python -m pip install -r requirements.txt
if errorlevel 1 goto :error
if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo Created .env from .env.example. Edit SECRET_KEY before using beyond local testing.
)
python scripts\init_db.py
if errorlevel 1 goto :error
echo Starting ResearchLens at http://127.0.0.1:5000
set "CHROME="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if defined CHROME (
  start "" cmd /c "timeout /t 3 /nobreak >nul & start \"\" \"%CHROME%\" http://127.0.0.1:5000"
) else (
  echo Chrome was not found in standard install locations. Opening your default browser instead.
  start "" cmd /c "timeout /t 3 /nobreak >nul & start http://127.0.0.1:5000"
)
python run.py
goto :eof
:error
echo.
echo STARTUP FAILED. Review the error above.
pause
exit /b 1
