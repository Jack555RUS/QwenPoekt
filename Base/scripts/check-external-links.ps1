# check-external-links.ps1 — Проверка внешних ссылок (HTTPS)
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Проверка внешних ссылок с таймаутом и повторными попытками

param(
    [string]$Path = ".",       # Путь для сканирования
    [string]$Pattern = "*.md", # Шаблон файлов
    [switch]$Recursive,        # Рекурсивно
    [int]$Timeout = 10000,     # Таймаут в мс (10 сек)
    [int]$Retries = 3,         # Количество попыток
    [int]$RetryDelay = 10000,  # Задержка между попытками в мс (10 сек)
    [switch]$Verbose           # Подробный вывод
)

$ErrorActionPreference = "Continue"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$ReportPath = Join-Path $BasePath "reports\EXTERNAL_LINKS_REPORT.md"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

function Get-MarkdownLinks {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $links = @()

    # Поиск ссылок: [text](url)
    $pattern = '\[([^\]]+)\]\(([^)]+)\)'
    $matches = [regex]::Matches($content, $pattern)

    foreach ($match in $matches) {
        $text = $match.Groups[1].Value
        $url = $match.Groups[2].Value

        # Пропускаем локальные ссылки и якоря
        if ($url -notmatch '^https?://' -or $url -match '^#' -or $url -match '^mailto:') {
            continue
        }

        $links += @{
            Text = $text
            Url = $url
            Line = $content.Substring(0, $match.Index).Split("`n").Count
        }
    }

    return $links
}

function Check-Url {
    param(
        [string]$Url,
        [int]$Timeout,
        [int]$Retries,
        [int]$RetryDelay
    )

    $attempt = 1
    $lastError = $null

    while ($attempt -le $Retries) {
        $tryGet = $false  # Флаг: пробуем GET вместо HEAD

        try {
            # Создаём запрос
            $request = [System.Net.WebRequest]::Create($Url)
            $request.Timeout = $Timeout

            # Попытка 1: HEAD (быстро)
            # Попытка 2+: GET (если HEAD заблокирован)
            if ($tryGet) {
                $request.Method = "GET"
                $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            } else {
                $request.Method = "HEAD"
            }

            # Получаем ответ
            $response = $request.GetResponse()
            $statusCode = [int]$response.StatusCode

            # Закрываем соединение (не скачиваем контент)
            $response.Close()

            # Успех: 2xx статус
            if ($statusCode -ge 200 -and $statusCode -lt 300) {
                return @{
                    Status = "OK"
                    Code = $statusCode
                    Attempts = $attempt
                    Method = $(if ($tryGet) { "GET" } else { "HEAD" })
                }
            }
            # Перенаправление: 3xx (считаем успехом)
            elseif ($statusCode -ge 300 -and $statusCode -lt 400) {
                return @{
                    Status = "Redirect"
                    Code = $statusCode
                    Attempts = $attempt
                    Method = $(if ($tryGet) { "GET" } else { "HEAD" })
                }
            }
            # Ошибка клиента/сервера: 4xx, 5xx
            else {
                # Если 403 Forbidden — пробуем GET метод
                if ($statusCode -eq 403 -and -not $tryGet) {
                    if ($Verbose) {
                        Write-Log "  HEAD заблокирован (403), пробуем GET..." -Color "Yellow"
                    }
                    $tryGet = $true
                    continue  # Повторяем текущую попытку с GET
                }

                $lastError = "HTTP $statusCode"
                if ($Verbose) {
                    Write-Log "  Попытка $attempt/$Retries ($(if ($tryGet) { 'GET' } else { 'HEAD' })) : HTTP $statusCode" -Color "Yellow"
                }
            }
        }
        catch [System.Net.WebException] {
            $httpCode = $null
            if ($_.Exception.Response -ne $null) {
                $httpCode = [int]$_.Exception.Response.StatusCode
            }

            # Если 403 Forbidden — пробуем GET метод
            if ($httpCode -eq 403 -and -not $tryGet) {
                if ($Verbose) {
                    Write-Log "  HEAD заблокирован (403), пробуем GET..." -Color "Yellow"
                }
                $tryGet = $true
                continue  # Повторяем текущую попытку с GET
            }

            $lastError = $_.Exception.Message

            if ($Verbose) {
                Write-Log "  Попытка $attempt/$Retries ($(if ($tryGet) { 'GET' } else { 'HEAD' })) : $($_.Exception.Message)" -Color "Yellow"
            }
        }
        catch {
            $lastError = $_.Exception.Message

            if ($Verbose) {
                Write-Log "  Попытка $attempt/$Retries : $_" -Color "Yellow"
            }
        }

        # Если это не последняя попытка — ждём
        if ($attempt -lt $Retries) {
            if ($Verbose) {
                Write-Log "  Задержка $($RetryDelay/1000) сек перед следующей попыткой..." -Color "Gray"
            }
            Start-Sleep -Milliseconds $RetryDelay
        }

        $attempt++
    }

    # Все попытки исчерпаны
    return @{
        Status = "Failed"
        Code = 0
        Attempts = $Retries
        Error = $lastError
    }
}

function Check-External-Links {
    param(
        [string]$SearchPath,
        [int]$Timeout,
        [int]$Retries,
        [int]$RetryDelay,
        [switch]$Recursive
    )

    $getParams = @{
        Path = $SearchPath
        Include = $Pattern
        ErrorAction = "SilentlyContinue"
    }

    if ($Recursive) {
        $getParams.Recurse = $true
    }

    $files = Get-ChildItem @getParams
    Write-Log "📊 Найдено файлов: $($files.Count)" -Color "Cyan"
    Write-Log ""

    $results = @{
        Total = 0
        Valid = 0
        Redirect = 0
        Broken = @()
        Files = @()
        StartTime = Get-Date
    }

    foreach ($file in $files) {
        Write-Log "📄 $($file.Name)" -Color "Gray"

        $links = Get-MarkdownLinks -FilePath $file.FullName
        $fileResults = @{
            File = $file.FullName
            Links = @()
        }

        foreach ($link in $links) {
            $results.Total++

            if ($Verbose) {
                Write-Log "  Проверка: $($link.Url)..." -Color "Gray"
            }

            $checkResult = Check-Url -Url $link.Url -Timeout $Timeout -Retries $Retries -RetryDelay $RetryDelay

            if ($checkResult.Status -eq "OK") {
                $results.Valid++
                if ($Verbose) {
                    Write-Log "  ✅ $($link.Text) → $($link.Url) ($($checkResult.Code), $($checkResult.Attempts) попыток)" -Color "Green"
                }
            }
            elseif ($checkResult.Status -eq "Redirect") {
                $results.Redirect++
                if ($Verbose) {
                    Write-Log "  ⚠️  $($link.Text) → $($link.Url) ($($checkResult.Code), $($checkResult.Attempts) попыток)" -Color "Yellow"
                }
            }
            else {
                $results.Broken += @{
                    File = $file.FullName
                    Line = $link.Line
                    Text = $link.Text
                    Url = $link.Url
                    Error = $checkResult.Error
                    Attempts = $checkResult.Attempts
                }
                Write-Log "  ❌ $($link.Text) → $($link.Url) (строка $($link.Line), ошибка: $($checkResult.Error))" -Color "Red"
            }

            $fileResults.Links += @{
                Link = $link
                Result = $checkResult
            }
        }

        $results.Files += $fileResults
        Write-Log ""
    }

    $results.EndTime = Get-Date
    $results.Duration = $results.EndTime - $results.StartTime

    return $results
}

function Generate-Report {
    param([object]$Results)

    $durationFormatted = "{0}:{1}:{2}" -f 
        [int]$Results.Duration.TotalHours,
        $Results.Duration.Minutes,
        $Results.Duration.Seconds

    $report = @"
# 🔗 ОТЧЁТ О ПРОВЕРКЕ ВНЕШНИХ ССЫЛОК

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Путь:** $BasePath
**Таймаут:** $($Results.Timeout/1000) сек
**Попыток:** $($Results.Retries)
**Длительность:** $durationFormatted

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего ссылок** | $($Results.Total) |
| **Рабочих (HEAD)** | $(($Results.Files.Links | Where-Object { $_.Result.Status -eq "OK" -and $_.Result.Method -eq "HEAD" }).Count) |
| **Рабочих (GET)** | $(($Results.Files.Links | Where-Object { $_.Result.Status -eq "OK" -and $_.Result.Method -eq "GET" }).Count) |
| **Перенаправлений** | $($Results.Redirect) |
| **Битых** | $($Results.Broken.Count) |
| **Процент рабочих** | $(if ($Results.Total -gt 0) { [Math]::Round(($Results.Valid + $Results.Redirect) / $Results.Total * 100, 2) } else { 0 })% |

---

## ❌ БИТЫЕ ССЫЛКИ

"@

    if ($Results.Broken.Count -eq 0) {
        $report += "`n**Битых ссылок не найдено!** ✅`n"
    } else {
        $report += "`n"

        # Группировка по файлам
        $grouped = $Results.Broken | Group-Object { $_.File }

        foreach ($group in $grouped) {
            $fileName = Split-Path $group.Name -Leaf
            $report += "### 📄 $fileName`n`n"
            $report += "| Строка | Текст | Ссылка | Ошибка | Попыток |`n"
            $report += "|--------|-------|--------|--------|---------|`n"

            foreach ($item in $group.Group) {
                $report += "| $($item.Line) | $($item.Text) | $($item.Url) | $($item.Error) | $($item.Attempts) |`n"
            }

            $report += "`n"
        }
    }

    $report += @"

---

## 📈 ДЕТАЛИ ПО ФАЙЛАМ

"@

    foreach ($fileResult in $Results.Files) {
        $fileName = Split-Path $fileResult.File -Leaf
        $totalLinks = $fileResult.Links.Count
        $okLinks = ($fileResult.Links | Where-Object { $_.Result.Status -eq "OK" }).Count
        $redirectLinks = ($fileResult.Links | Where-Object { $_.Result.Status -eq "Redirect" }).Count
        $brokenLinks = ($fileResult.Links | Where-Object { $_.Result.Status -eq "Failed" }).Count

        $report += "### 📄 $fileName`n"
        $report += "- Всего: $totalLinks`n"
        $report += "- ✅ Рабочих: $okLinks`n"
        $report += "- ⚠️  Перенаправлений: $redirectLinks`n"
        $report += "- ❌ Битых: $brokenLinks`n`n"
    }

    $report += @"

---

## 🔧 ПАРАМЕТРЫ ПРОВЕРКИ

| Параметр | Значение |
|----------|----------|
| **Таймаут** | $($Results.Timeout/1000) сек |
| **Попыток** | $($Results.Retries) |
| **Задержка** | $($Results.RetryDelay/1000) сек |

---

**Скрипт:** check-external-links.ps1
**Версия:** 1.0
**Дата:** 2026-03-04
"@

    return $report
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Log ""
Write-Log "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Log "║         ПРОВЕРКА ВНЕШНИХ ССЫЛОК (HTTPS)                  ║" -ForegroundColor Cyan
Write-Log "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Log ""
Write-Log "Параметры:" -ForegroundColor Yellow
Write-Log "  Путь: $Path" -ForegroundColor Gray
Write-Log "  Шаблон: $Pattern" -ForegroundColor Gray
Write-Log "  Рекурсивно: $(if ($Recursive) { 'Да' } else { 'Нет' })" -ForegroundColor Gray
Write-Log "  Таймаут: $($Timeout/1000) сек" -ForegroundColor Gray
Write-Log "  Попыток: $Retries" -ForegroundColor Gray
Write-Log "  Задержка: $($RetryDelay/1000) сек" -ForegroundColor Gray
Write-Log ""

# Проверка внешних ссылок
$results = Check-External-Links -SearchPath $Path -Timeout $Timeout -Retries $Retries -RetryDelay $RetryDelay -Recursive:$Recursive

# Генерация отчёта
Write-Log "📊 Генерация отчёта..." -Color "Cyan"
$report = Generate-Report -Results $results

# Сохранение отчёта
$report | Out-File -FilePath $ReportPath -Encoding UTF8 -NoBOM
Write-Log "✅ Отчёт сохранён: $ReportPath" -Color "Green"
Write-Log ""

# Итоги
Write-Log "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Log "║                    ИТОГИ                                 ║" -ForegroundColor Cyan
Write-Log "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Log ""
Write-Log "Всего ссылок: $($results.Total)" -Color White
Write-Log "✅ Рабочих: $($results.Valid)" -Color Green
Write-Log "⚠️  Перенаправлений: $($results.Redirect)" -Color Yellow
Write-Log "❌ Битых: $($results.Broken.Count)" -Color Red
$durationStr = "{0}:{1}:{2}" -f 
    [int]$results.Duration.TotalHours,
    $results.Duration.Minutes,
    $results.Duration.Seconds
Write-Log "Длительность: $durationStr" -Color Gray
Write-Log ""

if ($results.Broken.Count -gt 0) {
    Write-Log "💡 Рекомендуется:" -ForegroundColor Cyan
    Write-Log "  1. Проверить битые ссылки вручную" -ForegroundColor Gray
    Write-Log "  2. Обновить или удалить нерабочие" -ForegroundColor Gray
    Write-Log "  3. Запустить fix-broken-links.ps1 для исправления" -ForegroundColor Gray
    Write-Log ""
}

Write-Log "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Log "Следующий шаг: Проверить отчёт в reports\EXTERNAL_LINKS_REPORT.md" -ForegroundColor White
Write-Log "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
