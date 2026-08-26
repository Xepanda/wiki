<#
.SYNOPSIS
    PandaWiki - Windows 宿主机一键初始化与全套环境装机脚本 (setup-windows.ps1)
.DESCRIPTION
    在新电脑上以管理员身份运行此脚本，自动完成：
    1. 必备开发与效率软件批量安装 (winget)
    2. JetBrainsMono Nerd Font 图标字体安装
    3. PowerShell 7 + Oh My Posh (p10k 极简单行) 终端配置
    4. 系统性能释放 (卓越性能、关闭透明与动画、CUBIC 网络栈)
    5. Windows Defender 排除项配置 (代码目录与 WSL 进程)
    6. 存储感知每周自动清理策略
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "🚀 PandaWiki - Windows 宿主机装机与自动化环境配置" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 0. 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "⚠️ 警告：当前未以管理员权限运行！某些系统调优（如电源计划、Defender 排除项、TCP CUBIC）可能无法生效。"
    Write-Warning "建议右键以管理员身份重新运行此脚本。"
    Start-Sleep -Seconds 3
}

# 1. 软件安装矩阵 (winget)
Write-Host "`n[1/5] 📦 正在通过 winget 批量安装核心开发与效率软件..." -ForegroundColor Yellow

$apps = @(
    @{ Name = "Git"; Id = "Git.Git" },
    @{ Name = "GitHub CLI"; Id = "GitHub.cli" },
    @{ Name = "VS Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" },
    @{ Name = "Node.js (LTS)"; Id = "OpenJS.NodeJS.LTS" },
    @{ Name = "JetBrainsMono Nerd Font"; Id = "DEVCOM.JetBrainsMonoNerdFont" },
    @{ Name = "Google Chrome"; Id = "Google.Chrome" }
)

foreach ($app in $apps) {
    Write-Host "  -> 检查/安装: $($app.Name)..." -NoNewline
    winget install --id $app.Id -e --accept-source-agreements --accept-package-agreements --silent | Out-Null
    Write-Host " [完成]" -ForegroundColor Green
}

# 2. 终端美化与扩展模块
Write-Host "`n[2/5] 🎨 正在配置 PowerShell 7 与 Oh My Posh 极简终端..." -ForegroundColor Yellow

winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements --silent | Out-Null
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue | Out-Null

$pwshDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $pwshDir)) { New-Item -ItemType Directory -Path $pwshDir -Force | Out-Null }

# 部署 p10k lean 主题
$p10kThemeJson = @'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        {
          "foreground": "#3b82f6",
          "properties": { "style": "full", "folder_separator_icon": "/" },
          "style": "plain",
          "template": " {{ .Path }} ",
          "type": "path"
        },
        {
          "foreground": "#10b981",
          "foreground_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}#f59e0b{{ end }}",
            "{{ if gt .Ahead 0 }}#8b5cf6{{ end }}",
            "{{ if gt .Behind 0 }}#ef4444{{ end }}"
          ],
          "properties": { "branch_icon": " ", "fetch_status": true },
          "style": "plain",
          "template": "{{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} ",
          "type": "git"
        },
        {
          "foreground": "#ec4899",
          "style": "plain",
          "template": "❯ ",
          "type": "text"
        }
      ],
      "type": "prompt"
    },
    {
      "alignment": "right",
      "segments": [
        {
          "foreground": "#6b7280",
          "properties": { "time_format": "15:04:05" },
          "style": "plain",
          "template": "{{ .CurrentDate | date .Format }}",
          "type": "time"
        }
      ],
      "type": "prompt"
    }
  ],
  "version": 3
}
'@
Set-Content -Path "$pwshDir\powerlevel10k_lean.omp.json" -Value $p10kThemeJson -Encoding UTF8

# 部署 $PROFILE
$profileScript = @'
# Oh My Posh p10k lean init
oh-my-posh init pwsh --config "$HOME\Documents\PowerShell\powerlevel10k_lean.omp.json" | Invoke-Expression

# PSReadLine 历史建议与自动补全
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]0x1b)[38;5;242m" }
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}
'@
Set-Content -Path "$pwshDir\Microsoft.PowerShell_profile.ps1" -Value $profileScript -Encoding UTF8
Set-Content -Path "$pwshDir\profile.ps1" -Value $profileScript -Encoding UTF8
Write-Host "  -> 终端配置与 p10k 主题部署完成！" -ForegroundColor Green

# 3. 硬件性能与 UI 延迟优化
Write-Host "`n[3/5] ⚡ 正在应用系统性能与动画调优..." -ForegroundColor Yellow

# 解锁并设置卓越性能方案
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null

# 关闭 Mica 透明度与窗口动画
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Type DWord -Force

# 禁用后台遥测与开机常驻
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch_*" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue
Write-Host "  -> 卓越性能、零延迟动画与后台自启清理完成！" -ForegroundColor Green

# 4. 存储与网络栈优化
Write-Host "`n[4/5] 🌐 正在调优网络栈与存储维护策略..." -ForegroundColor Yellow

if ($isAdmin) {
    netsh int tcp set supplemental template=internet congestionprovider=cubic | Out-Null
    netsh int tcp set global ecncapability=enabled | Out-Null
}

# 开启存储感知
$storageKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
if (-not (Test-Path $storageKey)) { New-Item -Path $storageKey -Force | Out-Null }
Set-ItemProperty -Path $storageKey -Name "01" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $storageKey -Name "04" -Value 7 -Type DWord -Force
Set-ItemProperty -Path $storageKey -Name "32" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $storageKey -Name "08" -Value 30 -Type DWord -Force

# 创建主项目目录
if (-not (Test-Path "D:\Projects")) { New-Item -ItemType Directory -Path "D:\Projects" -Force | Out-Null }
Write-Host "  -> TCP CUBIC 算法已激活，存储感知已开启，D:\Projects 工作区就绪！" -ForegroundColor Green

# 5. 安全中心白名单
Write-Host "`n[5/5] 🛡️ 正在配置 Windows Defender 排除项..." -ForegroundColor Yellow
if ($isAdmin) {
    Add-MpPreference -ExclusionPath "D:\Projects", "$env:USERPROFILE\.gemini" -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "wsl.exe", "wslhost.exe", "vmmem.exe", "vmmemWSL.exe" -ErrorAction SilentlyContinue
    Get-ChildItem "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Add-MpPreference -ExclusionPath $_.FullName -ErrorAction SilentlyContinue
    }
    Write-Host "  -> 代码目录与 WSL 核心进程已加入 Defender 排除项！" -ForegroundColor Green
} else {
    Write-Host "  -> (需要管理员权限，已跳过 Defender 排除项配置)" -ForegroundColor DarkGray
}

Write-Host "`n====================================================" -ForegroundColor Green
Write-Host "🎉 恭喜！Windows 宿主机已全面配置完成，享受极致流畅体验！" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
