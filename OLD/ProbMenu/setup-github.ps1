# =============================================================================
# Скрипт автоматической настройки Git и GitHub
# =============================================================================

param(
    [string]$GitHubUsername = "",
    [string]$RepositoryName = "DragRace",
    [string]$ProjectPath = "D:\QwenPoekt\ProbMenu"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Actions Auto-Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Проверка Git
# =============================================================================
Write-Host "--- Checking Git Installation ---" -ForegroundColor Yellow

$gitPath = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitPath) {
    Write-Host "[ERROR] Git not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git:" -ForegroundColor Yellow
    Write-Host "  winget install Git.Git" -ForegroundColor Gray
    Write-Host "  Or: https://git-scm.com/download/win" -ForegroundColor Gray
    Write-Host ""
    Write-Host "After installation, run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Git found: $($gitPath.Source)" -ForegroundColor Green

# =============================================================================
# Проверка GitHub CLI
# =============================================================================
Write-Host ""
Write-Host "--- Checking GitHub CLI ---" -ForegroundColor Yellow

$ghPath = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghPath) {
    Write-Host "[WARNING] GitHub CLI not found" -ForegroundColor Yellow
    Write-Host "  You'll need to create repository manually via browser" -ForegroundColor Gray
    Write-Host "  Or install: winget install GitHub.cli" -ForegroundColor Gray
} else {
    Write-Host "[OK] GitHub CLI found: $($ghPath.Source)" -ForegroundColor Green
}

# =============================================================================
# Инициализация Git
# =============================================================================
Write-Host ""
Write-Host "--- Initializing Git Repository ---" -ForegroundColor Yellow

Set-Location $ProjectPath

# Проверка, инициализирован ли уже Git
if (Test-Path ".git") {
    Write-Host "[INFO] Git repository already initialized" -ForegroundColor Cyan
} else {
    git init
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Git repository initialized" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to initialize Git" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Настройка .gitignore
# =============================================================================
Write-Host ""
Write-Host "--- Creating .gitignore ---" -ForegroundColor Yellow

if (Test-Path ".gitignore") {
    Write-Host "[INFO] .gitignore already exists" -ForegroundColor Cyan
} else {
    $gitignoreContent = @"
# Unity
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
*.pidb.meta
*.pdb.meta
*.mdb.meta
*.apk
*.aab
*.unitypackage

# OS
.DS_Store
Thumbs.db
desktop.ini

# IDE
.vs/
.vscode/
*.suo
*.user
*.userosscache
*.suo.user

# Logs
*.log
[Ll]ogs/

# Secrets
.env
*.env.local
secrets/
"@

    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "[OK] .gitignore created" -ForegroundColor Green
}

# =============================================================================
# Добавление файлов
# =============================================================================
Write-Host ""
Write-Host "--- Adding Files to Git ---" -ForegroundColor Yellow

git add .
Write-Host "[OK] Files added" -ForegroundColor Green

# Проверка на большие файлы (для LFS)
$largeFiles = git status --porcelain | Where-Object { $_.Length -gt 50 }
if ($largeFiles) {
    Write-Host "[WARNING] Large files detected. Consider using Git LFS:" -ForegroundColor Yellow
    Write-Host "  git lfs install" -ForegroundColor Gray
    Write-Host "  git lfs track '*.png' '*.fbx' '*.unity'" -ForegroundColor Gray
}

# =============================================================================
# Первый коммит
# =============================================================================
Write-Host ""
Write-Host "--- Creating Initial Commit ---" -ForegroundColor Yellow

$commitMessage = "Initial commit - DragRace Unity Project with CI/CD"

# Проверка, есть ли изменения
$status = git status --porcelain
if (-not $status) {
    Write-Host "[INFO] No changes to commit" -ForegroundColor Cyan
} else {
    git commit -m $commitMessage
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Initial commit created" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create commit" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Создание remote (если указан username)
# =============================================================================
Write-Host ""
Write-Host "--- Setting Up Remote Repository ---" -ForegroundColor Yellow

$currentRemote = git remote get-url origin 2>$null

if ($currentRemote) {
    Write-Host "[INFO] Remote 'origin' already configured: $currentRemote" -ForegroundColor Cyan
} else {
    if ($GitHubUsername) {
        $remoteUrl = "https://github.com/$GitHubUsername/$RepositoryName.git"
        Write-Host "Remote URL: $remoteUrl" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To add remote, run:" -ForegroundColor Yellow
        Write-Host "  git remote add origin $remoteUrl" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "[INFO] GitHub username not provided" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To configure remote later:" -ForegroundColor Yellow
        Write-Host "  git remote add origin https://github.com/USERNAME/REPO.git" -ForegroundColor Gray
    }
}

# =============================================================================
# Инструкция для GitHub
# =============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Create repository on GitHub:" -ForegroundColor Yellow
Write-Host "   https://github.com/new" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Repository name: $RepositoryName" -ForegroundColor Gray
Write-Host "   Visibility: Private (recommended)" -ForegroundColor Gray
Write-Host "   DO NOT create with README" -ForegroundColor Red
Write-Host ""
Write-Host "3. Add secrets (Settings → Secrets and variables → Actions):" -ForegroundColor Yellow
Write-Host "   UNITY_EMAIL=jackal555rus@gmail.com" -ForegroundColor Gray
Write-Host "   UNITY_PASSWORD=Unit0579" -ForegroundColor Gray
Write-Host "   UNITY_PERSONAL_TOKEN=eRctBAYhyLTHFJo-OTzw__dUJIgU2vrQ" -ForegroundColor Gray
Write-Host "   UNITY_VERSION=6000.3.10f1" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Push to GitHub:" -ForegroundColor Yellow
Write-Host "   git remote add origin https://github.com/USERNAME/$RepositoryName.git" -ForegroundColor Gray
Write-Host "   git push -u origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Check Actions:" -ForegroundColor Yellow
Write-Host "   https://github.com/USERNAME/$RepositoryName/actions" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# Сохранение инструкции
# =============================================================================
$instructionFile = "GITHUB_SETUP_INSTRUCTIONS.txt"
$instructions = @"
===========================================
GITHUB ACTIONS SETUP INSTRUCTIONS
===========================================

1. CREATE REPOSITORY:
   Go to: https://github.com/new
   Name: $RepositoryName
   Visibility: Private
   DO NOT create with README

2. ADD SECRETS:
   Settings → Secrets and variables → Actions
   
   UNITY_EMAIL=jackal555rus@gmail.com
   UNITY_PASSWORD=Unit0579
   UNITY_PERSONAL_TOKEN=eRctBAYhyLTHFJo-OTzw__dUJIgU2vrQ
   UNITY_VERSION=6000.3.10f1

3. PUSH TO GITHUB:
   git remote add origin https://github.com/YOUR_USERNAME/$RepositoryName.git
   git push -u origin main

4. CHECK ACTIONS:
   https://github.com/YOUR_USERNAME/$RepositoryName/actions

===========================================
"@

$instructions | Out-File -FilePath $instructionFile -Encoding UTF8
Write-Host "[OK] Instructions saved to $instructionFile" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
