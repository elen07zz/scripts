@echo off

REM Verifica si python.exe existe en python_embeded
if exist "python_embeded\python.exe" (
    set PYTHON_EXECUTABLE=python_embeded\python.exe
) else (
    REM Si no existe en python_embeded, verifica en venv\Scripts
    if exist "venv\Scripts\python.exe" (
        set PYTHON_EXECUTABLE=venv\Scripts\python.exe
    ) else (
        echo No se encontró Python en python_embeded ni en venv\Scripts.
        pause
        exit /b
    )
)

REM Verifica la version de Python en la ubicación seleccionada
for /f "tokens=2 delims= " %%a in ('%PYTHON_EXECUTABLE% --version') do set PYTHON_VERSION=%%a

REM Extrae la version principal y secundaria
for /f "tokens=1,2 delims=." %%b in ("%PYTHON_VERSION%") do (
    set PYTHON_MAJOR=%%b
    set PYTHON_MINOR=%%c
)

REM Determina la URL a descargar segun la version de Python
set WHL_URL=
if %PYTHON_MAJOR%==3 (
    if %PYTHON_MINOR% geq 9 if %PYTHON_MINOR% lss 10 set WHL_URL=https://github.com/woct0rdho/triton-windows/releases/download/v3.1.0-windows.post5/triton-3.1.0-cp39-cp39-win_amd64.whl
    if %PYTHON_MINOR% geq 10 if %PYTHON_MINOR% lss 11 set WHL_URL=https://github.com/woct0rdho/triton-windows/releases/download/v3.1.0-windows.post5/triton-3.1.0-cp310-cp310-win_amd64.whl
    if %PYTHON_MINOR% geq 11 if %PYTHON_MINOR% lss 12 set WHL_URL=https://github.com/woct0rdho/triton-windows/releases/download/v3.1.0-windows.post5/triton-3.1.0-cp311-cp311-win_amd64.whl
    if %PYTHON_MINOR% geq 12 if %PYTHON_MINOR% lss 13 set WHL_URL=https://github.com/woct0rdho/triton-windows/releases/download/v3.1.0-windows.post5/triton-3.1.0-cp312-cp312-win_amd64.whl
)

REM Comprueba si se establecio una URL valida
if "%WHL_URL%"=="" (
    echo No se encontró una versión compatible de Python.
    pause
    exit /b
)

REM Extrae el nombre del archivo de la URL
for %%i in (%WHL_URL%) do set WHL_FILE=%%~nxi

REM Descarga el archivo .whl correspondiente
powershell -command "Invoke-WebRequest -Uri %WHL_URL% -OutFile %WHL_FILE%"

REM Verifica si la descarga fue exitosa
if not exist "%WHL_FILE%" (
    echo Error al descargar %WHL_FILE%.
    pause
    exit /b
)

REM Instala el archivo .whl descargado
%PYTHON_EXECUTABLE% -m pip install --force-reinstall .\%WHL_FILE%

REM Verifica si la instalacion fue exitosa
if %errorlevel% equ 0 (
    echo Instalación exitosa.
) else (
    echo Fallo en la instalación.
)
pause