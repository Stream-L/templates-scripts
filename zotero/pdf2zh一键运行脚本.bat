@echo off
title Zotero PDF2ZH 一键启动工具
color 0a

echo =====================================================
echo     Zotero PDF2ZH 插件 —— 自动配置与启动脚本
echo =====================================================
echo.
echo 本脚本将自动完成以下操作：
echo   1) 检查 Conda 是否安装
echo   2) 检查当前目录是否已有 “zotero?pdf2zh” 文件夹
echo   3) 若无则从 GitHub 下载，有则进入项目目录
echo   4) 进入 server 子目录
echo   5) 创建或激活虚拟环境，安装依赖
echo   6) 启动服务（使用 README 中指定的启动命令）
echo.
pause

:: ——— 步骤 1：检查 Conda 是否安装 ———
echo [1/6] 正在检查 Conda 是否安装...
where conda >nul 2>nul
if %errorlevel% neq 0 (
    echo 未检测到 Conda。请先安装 Anaconda 或 Miniconda。
    echo 下载地址： https://www.anaconda.com/download
    pause
    exit /b
)
echo 检测到 Conda。

:: ——— 步骤 2：检查项目文件夹是否存在 ———
set "LOCALDIR=%~dp0"
set "PROJDIR=%LOCALDIR%zotero?pdf2zh"
echo [2/6] 检查当前目录是否已有 “zotero?pdf2zh” 文件夹...
if exist "%PROJDIR%" (
    echo 检测到 “%PROJDIR%”。
) else (
    echo 未检测到 “zotero?pdf2zh” 文件夹，正在从 GitHub 下载……
    cd /d "%LOCALDIR%"
    git clone https://github.com/guaguastandup/zotero-pdf2zh.git
    if %errorlevel% neq 0 (
        echo 下载失败，请检查网络或手动从 GitHub 下载项目。
        pause
        exit /b
    )
)

:: ——— 步骤 3：进入 server 子目录 ———
cd /d "%PROJDIR%\server"
echo 已切换至 “%CD%” 目录。

:: ——— 步骤 4：创建/激活虚拟环境 & 安装依赖 ———
echo [3/6] 创建或激活虚拟环境…
set "ENV_NAME=zotero_pdf2zh_env"
call conda info --envs | findstr /R /C:"%ENV_NAME%" >nul
if %errorlevel% neq 0 (
    echo 虚拟环境 “%ENV_NAME%” 未检测到，正在创建（Python?3.10）……
    call conda create -y -n %ENV_NAME% python=3.10
    if %errorlevel% neq 0 (
        echo 虚拟环境创建失败。
        pause
        exit /b
    )
) else (
    echo 虚拟环境 “%ENV_NAME%” 已存在。
)
echo 激活环境…
call conda activate %ENV_NAME%
if %errorlevel% neq 0 (
    echo 虚拟环境激活失败，请关闭此窗口并重新运行脚本。
    pause
    exit /b
)

echo 安装依赖（如果尚未安装）…
if exist "requirements.txt" (
    pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
) else (
    echo 未找到 requirements.txt，可能项目结构已变更。请手动检查 server 文件夹内是否有该文件。
)

:: ——— 步骤 5：启动服务 ———
echo [4/6] 启动服务中…
timeout /t 3 >nul

:: 以下命令按照 README 指定启动
python server.py --env_tool=conda
if %errorlevel% neq 0 (
    echo 服务启动失败。请查看上方错误并尝试手动运行： python server.py --env_tool=conda
    pause
    exit /b
)

echo.
echo 服务已启动，窗口请保持打开状态，以供 Zotero 插件使用。
echo 若需停止服务，请按 Ctrl+C 或直接关闭此窗口。
pause
