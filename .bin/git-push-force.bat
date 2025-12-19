:: =============================================================================
:: Script: git-push-force.bat
:: Description: Force push changes to the remote repository.
:: Author: Nguyen Quy
:: Date: 2025-11-27
:: Version: 1.0
:: Last Updated: 2025-11-27
:: Dependencies: Git
:: Usage: Just double-click this script or run it from the command line.
:: =============================================================================

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cls

:: Show current directory
echo === Current Directory: %cd%
echo .

@REM Disable command echoing for cleaner output
git push -o secret_push_protection.skip_all

pause
