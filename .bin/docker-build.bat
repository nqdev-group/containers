:: =============================================================================
:: Script: docker-build.bat
:: Description: Build Docker images for the project.
:: Author: Nguyen Quy
:: Date: 2025-11-13
:: Version: 1.1
:: Last Updated: 2025-11-13
:: Dependencies: Docker
:: Usage:
::   - Double-click this script, or
::   - Run from command line:
::       docker-build.bat [image_name] [tag]
:: Example:
::       docker-build.bat nqdev/wordpress latest
:: =============================================================================

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cls

echo ===============================================
echo    🐳 Docker Image Build Script
echo ===============================================

:: Set default values if arguments are not provided
set IMAGE_NAME=%~1
if "%IMAGE_NAME%"=="" set IMAGE_NAME=nqdev/wordpress

set TAG=%~2
if "%TAG%"=="" set TAG=latest

set DOCKERFILE_PATH=./nqdev/wordpress/6/debian-12/Dockerfile
set BUILD_CONTEXT=./nqdev/wordpress/6/debian-12

echo [🔍] Checking Docker installation...

:: Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [❌] Docker is not installed or not in PATH.
    echo Please install Docker Desktop or Docker CLI.
    pause
    exit /b 1
)

:: Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [⚠️] Docker daemon does not appear to be running.
    echo Please start Docker Desktop or the Docker service.
    pause
    exit /b 1
)

echo.
echo [🏗️] Building Docker image:
echo     Image: %IMAGE_NAME%:%TAG%
echo     Dockerfile: %DOCKERFILE_PATH%
echo     Context: %BUILD_CONTEXT%
echo.

:: Build the Docker image
docker buildx build -t %IMAGE_NAME%:%TAG% -f %DOCKERFILE_PATH% %BUILD_CONTEXT%

if %errorlevel%==0 (
    echo.
    echo [✅] Docker image built successfully: %IMAGE_NAME%:%TAG%
) else (
    echo.
    echo [❌] Docker build failed. Check the logs above.
)

echo.
pause
endlocal
