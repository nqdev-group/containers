:: =============================================================================
:: Script: run-dev.bat
:: Description: Start the development environment for the project.
:: Author: Nguyen Quy
:: Date: 2025-10-07
:: Version: 1.3
:: Last Updated: 2025-10-07
:: Dependencies: Node.js, npm, MongoDB, nssm (Non-Sucking Service Manager)
:: Usage:
::   run-dev.bat                   - không chạy format, lint, test
::   run-dev.bat --format          - chỉ chạy format
::   run-dev.bat --lint            - chỉ chạy lint fix
::   run-dev.bat --test            - chỉ chạy test + mở báo cáo coverage
::   run-dev.bat --format --lint   - chạy cả format và lint fix
:: =============================================================================

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cls

:: Show current directory
echo === Current Directory: %cd%
echo .

:: Parse command line arguments
set RUN_FORMAT=false
set RUN_LINT=false
set RUN_TEST=false

:parse_args
if "%~1"=="" goto args_done

if /i "%~1"=="--format" set RUN_FORMAT=true
if /i "%~1"=="--lint" set RUN_LINT=true
if /i "%~1"=="--test" set RUN_TEST=true

shift
goto parse_args

:args_done

:: Check MongoDB service status
echo === Checking MongoDB service (nqdev-mongodb-service) status ===
sc query "nqdev-mongodb-service" | findstr /i "RUNNING" > nul
if errorlevel 1 (
    echo MongoDB service is NOT running. Starting service...
    nssm start nqdev-mongodb-service
    :: net start nqdev-mongodb-service
    timeout /t 5 /nobreak > nul
) else (
    echo MongoDB service is already running.
)

:: Check if node_modules folder exists
if not exist node_modules (
    echo === node_modules not found. Installing npm packages ===
    call npm install --force --no-audit --no-fund --loglevel error
    if %ERRORLEVEL% NEQ 0 (
        echo !!! npm install failed. Please check the errors above.
        goto end
    )
) else (
    echo === node_modules already exists. Skipping npm install ===
)

:: Run code formatter if requested
if "%RUN_FORMAT%"=="true" (
    echo === Running code formatter ===
    call npm run format
    if %ERRORLEVEL% NEQ 0 (
        echo !!! npm run format failed. Please check the errors above.
        goto end
    )
)

:: Run lint fix if requested
if "%RUN_LINT%"=="true" (
    echo === Running lint fix ===
    call npm run lint:fix
    if %ERRORLEVEL% NEQ 0 (
        echo !!! npm run lint:fix failed. Please check the errors above.
        goto end
    )
)

:: Run test if requested
if "%RUN_TEST%"=="true" (
    echo === Running tests ===
    call npm run test
    if %ERRORLEVEL% NEQ 0 (
        echo !!! npm run test failed. Please check the errors above.
        goto end
    )

    :: Open coverage report if exists
    if exist coverage\lcov-report\index.html (
        echo === Opening test coverage report ===
        call start "" "coverage\lcov-report\index.html"
    ) else (
        echo !!! Coverage report not found.
    )
)

:: Run development server
echo === Starting development server ===
call npm run dev
if %ERRORLEVEL% NEQ 0 (
    echo !!! npm run dev failed. Please check the errors above.
    goto end
)

:end
echo.
echo === All done ===
pause
endlocal
