@echo off
setlocal EnableDelayedExpansion

echo Checking for Python installation...

:: Check if Python is installed
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python is not installed or not found in PATH.
    echo Please download and install Python from https://www.python.org/downloads/
    echo Ensure Python is added to your system PATH during installation.
    pause
    exit /b 1
)

:: Check Python version (optional, for debugging)
python --version
if %ERRORLEVEL% neq 0 (
    echo Failed to verify Python version. Please ensure Python is correctly installed.
    pause
    exit /b 1
)

echo Python found. Checking for pip...

:: Check if pip is installed
python -m pip --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo pip is not installed. Attempting to install pip...
    python -m ensurepip --upgrade
    python -m pip install --upgrade pip
    if %ERRORLEVEL% neq 0 (
        echo Failed to install pip. Please install pip manually.
        pause
        exit /b 1
    )
)

echo Upgrading pip to the latest version...
python -m pip install --upgrade pip
if %ERRORLEVEL% neq 0 (
    echo Warning: Failed to upgrade pip. Continuing with package installation...
)

echo Installing required Python packages...

:: List of required packages
set "packages=pyautogui opencv-python numpy colorama requests pygetwindow"

:: Install or update each package
for %%p in (%packages%) do (
    echo Installing or updating %%p...
    python -m pip install --upgrade %%p
    if %ERRORLEVEL% neq 0 (
        echo Failed to install or update %%p. Please check your internet connection or pip configuration.
        pause
        exit /b 1
    )
)

echo All required packages are installed or updated.

:: Check if ZenithAFK.py exists
if not exist "ZenithAFK.py" (
    echo ZenithAFK.py not found in the current directory.
    echo Please ensure ZenithAFK.py is in the same directory as this batch file.
    pause
    exit /b 1
)

echo Running ZenithAFK.py...
python ZenithAFK.py

:: Check if the script ran successfully
if %ERRORLEVEL% neq 0 (
    echo ZenithAFK.py failed to run. Please check the script for errors.
    pause
    exit /b 1
)

cls

echo ZenithAFK.py completed.
pause