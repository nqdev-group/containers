:: =============================================================================
:: Script: git-merge-main.bat
:: Description: Merge changes from the main branch into the current branch.
:: Author: Nguyen Quy
:: Date: 2025-10-07
:: Version: 1.0
:: Last Updated: 2025-10-07
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

:: Get and show current branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set current_branch=%%i
echo === You are on branch: !current_branch!
echo.

:: Fetch latest from origin
echo === Fetching latest from origin ===
git fetch origin --prune --prune-tags --force --verbose --tags --recurse-submodules
echo.

:: Merge 'origin/main' into current branch
echo === Merging 'origin/main' into !current_branch! ===
git merge origin/main
set mergeStatus=%ERRORLEVEL%
echo.

:: Kiểm tra merge thành công
if !mergeStatus! NEQ 0 (
    echo !!! Merge conflict detected. Please resolve conflicts manually.
    goto end
)

:: Kiểm tra có thay đổi để commit không
echo === Checking for changes to commit ===
git status --porcelain | findstr /r "^\(M\|A\|D\|R\)" >nul
if %ERRORLEVEL%==0 (
    echo === Committing merge changes ===
    git commit -am "Merge from origin/main"

    echo.
    echo === Pushing to origin/!current_branch! ===
    git push origin !current_branch!
) else (
    echo === No changes to commit. Nothing to push.
)

:end
echo.
echo === All done ===
pause
endlocal
