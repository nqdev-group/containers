:: =============================================================================
:: Script: git-cleaner.bat
:: Description: Clean up and optimize the local Git repository.
:: Author: Nguyen Quy
:: Date: 2025-11-13
:: Version: 1.1
:: Last Updated: 2025-11-13
:: Dependencies: Git
:: Usage: Double-click this script or run it from the command line.
:: =============================================================================

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cls

echo ===============================================
echo   🧹 Git Repository Cleaner & Optimizer
echo ===============================================

:: Check if Git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [❌] Git is not installed or not in PATH.
    echo Please install Git before running this script.
    pause
    exit /b 1
)

:: Check if we are inside a Git repository
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [⚠️] This folder is not a Git repository.
    echo Please navigate to a valid Git repository folder.
    pause
    exit /b 1
)

echo [🔍] Cleaning and optimizing Git repository...
echo.

:: Perform garbage collection and cleanup
git gc --prune=now --aggressive --force

if %errorlevel%==0 (
    echo.
    echo [✅] Git cleanup and optimization completed successfully!
) else (
    echo.
    echo [❌] Something went wrong during cleanup.
)

echo.
pause
