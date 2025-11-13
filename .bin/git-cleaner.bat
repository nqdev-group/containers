@REM Garbage Collection
@REM Dọn Dẹp Thư Mục .git
@REM git-gc - Cleanup unnecessary files and optimize the local repository
@REM git gc [--aggressive] [--auto] [--quiet] [--prune=<date> | --no-prune] [--force] [--keep-largest-pack]

@REM thu dọn rác, nén dữ liệu và loại bỏ các đối tượng không còn tham chiếu từ bất kỳ nhánh nào
git gc --prune=now --force --aggressive

pause
