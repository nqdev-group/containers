:: =============================================================================
:: Script: git-cleaner.bat
:: Description: Clean up the local Git repository by performing garbage collection.
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

@REM Garbage Collection
@REM Dọn Dẹp Thư Mục .git
@REM git-gc - Cleanup unnecessary files and optimize the local repository
@REM git gc [--aggressive] [--auto] [--quiet] [--prune=<date> | --no-prune] [--force] [--keep-largest-pack]

@REM thu dọn rác, nén dữ liệu và loại bỏ các đối tượng không còn tham chiếu từ bất kỳ nhánh nào
git gc --prune=now --force --aggressive

pause
