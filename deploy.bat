@echo off
setlocal

rem 设置源目录和目标目录
set "source_dir=C:\projects\HugoBlog\destination"
set "target_dir=C:\projects\wangyongcong.github.io"

rem 删除目标目录下的所有文件及子目录，但排除以 "." 开头的隐藏目录
echo Deleting old files in target directory...
for /f "tokens=* delims=" %%a in ('dir /b /ad "%target_dir%" ^| findstr /v "^\.git$"') do (
    rmdir /s /q "%target_dir%\%%a"
)

for /f "tokens=* delims=" %%b in ('dir /b /a-d "%target_dir%" ^| findstr /v "^\.git$"') do (
    del /q "%target_dir%\%%b"
)

rem 复制源目录到目标目录
echo Copying source directory to target directory...
xcopy /e /i "%source_dir%" "%target_dir%"

echo Task completed.
pause