:: =============================================================================
:: Script: git-fetch.bat
:: Description: Fetch updates from the remote Git repository.
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

@REM Fetch Updates from Remote Repository
@REM Lấy Cập Nhật Từ Kho Lưu Trữ Từ Xa
@REM git-fetch - Download objects and refs from another repository
@REM git fetch [--all] [--append] [--depth=<depth>] [--dry-run] [--force] [--prune] [--prune-tags] [--tags] [--recurse-submodules=<on-demand|no|yes>] [<repository> [<refspec>...]]
git fetch --prune --prune-tags --force --verbose --tags --recurse-submodules

:: Show Updated Branches Info After Fetching
echo .=== Updated Branches After Fetching:
git branch -vv

pause
