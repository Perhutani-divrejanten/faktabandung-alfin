# Rebrand dari Fakta bandung ke Fakta bandung
# Script ini melakukan rebrand lengkap dengan backup otomatis

# Set encoding ke UTF-8
$PSDefaultParameterValues['*:Encoding'] = 'UTF8'
[System.Environment]::SetEnvironmentVariable('PYTHONIOENCODING', 'utf-8')

# Variables
$WorkspaceRoot = $PSScriptRoot
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$LogFile = Join-Path $WorkspaceRoot "rebrand-$Timestamp.log"
$ErrorLog = @()
$FileChanges = @{
    "main_pages" = 0
    "article_pages" = 0
    "css_files" = 0
    "package_files" = 0
    "docs" = 0
    "config_files" = 0
}

# Logging function
function Write-Log {
    param ([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Type] $Message"
    Write-Host $logLine
    Add-Content -Path $LogFile -Value $logLine -Encoding UTF8
}

# Error logging function
function Write-ErrorLog {
    param ([string]$Message)
    Write-Log -Message $Message -Type "ERROR"
    $ErrorLog += $Message
}

# Backup function
function Backup-File {
    param ([string]$FilePath)
    if (Test-Path $FilePath) {
        $BackupPath = "$FilePath.bak.$Timestamp"
        Copy-Item -Path $FilePath -Destination $BackupPath -Force
        Write-Log -Message "Backup created: $BackupPath"
        return $BackupPath
    }
}

Write-Log -Message "===== REBRAND WARTA JANTEN DIMULAI ====="
Write-Log -Message "Root path: $WorkspaceRoot"

# 1. BACKUP CRITICAL FILES
Write-Log -Message "--- STEP 1: Backup critical files ---"
if (Test-Path (Join-Path $WorkspaceRoot "articles.json")) {
    Backup-File -FilePath (Join-Path $WorkspaceRoot "articles.json")
}

# 2. REPLACE BRANDING IN HTML FILES
Write-Log -Message "--- STEP 2: Replacing branding in HTML files ---"

$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File | Where-Object { $_.FullName -notlike "*\archive\*" }

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Define replacement patterns
        $replacements = @(
            @{ Old = "Fakta bandung"; New = "Fakta bandung" },
            @{ Old = "Fakta bandung"; New = "Fakta bandung" },
            @{ Old = "faktabandung"; New = "faktabandung" },
            # Social media links
            @{ Old = "https://twitter.com/faktabandung"; New = "https://twitter.com/faktabandung" },
            @{ Old = "https://facebook.com/faktabandung"; New = "https://facebook.com/faktabandung" },
            @{ Old = "https://instagram.com/faktabandung"; New = "https://instagram.com/faktabandung" },
            @{ Old = "https://youtube.com/@faktabandung"; New = "https://youtube.com/@faktabandung" },
            @{ Old = "https://linkedin.com/company/faktabandung"; New = "https://linkedin.com/company/faktabandung" },
            # Email
            @{ Old = "faktabandung@gmail.com"; New = "faktabandung@gmail.com" },
            # Logo references
            @{ Old = 'alt="Fakta bandung"'; New = 'alt="Fakta bandung"' }
        )
        
        foreach ($replacement in $replacements) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
        }
        
        # Check if changes were made
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            
            # Categorize file
            if ($file.FullName -like "*\article\*") {
                $FileChanges["article_pages"] += 1
            } else {
                $FileChanges["main_pages"] += 1
            }
            
            Write-Log -Message "Updated: $($file.Name)"
        }
    } catch {
        Write-ErrorLog -Message "Error processing $($file.FullName): $_"
    }
}

# 3. REPLACE COLORS IN CSS FILES
Write-Log -Message "--- STEP 3: Replacing colors in CSS files ---"

$cssFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.css" -File

foreach ($file in $cssFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Color replacements
        $colorReplacements = @(
            @{ Old = "#2563EB"; New = "#2563EB" },          # Primary: kuning -> hijau
            @{ Old = "#ffcc00"; New = "#2563EB" },
            @{ Old = "rgb(255, 204, 0)"; New = "rgb(6, 95, 70)" },
            @{ Old = "#5C3D1A"; New = "#5C3D1A" },          # Secondary: abu -> biru
            @{ Old = "#1E293B"; New = "#1E293B" },          # Dark: hitam -> darkgreen
            # Additional color mappings if needed
            @{ Old = "#1e2024"; New = "#1E293B" }
        )
        
        foreach ($replacement in $colorReplacements) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $FileChanges["css_files"] += 1
            Write-Log -Message "Updated CSS colors: $($file.Name)"
        }
    } catch {
        Write-ErrorLog -Message "Error processing CSS $($file.FullName): $_"
    }
}

# 4. UPDATE PACKAGE.JSON
Write-Log -Message "--- STEP 4: Updating package.json metadata ---"

$packageJsonFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "package.json" -File

foreach ($file in $packageJsonFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        $replacements = @(
            @{ Old = """name"": ""faktabandung"""; New = """name"": ""faktabandung""" },
            @{ Old = """name"": ""faktabandung-article-generator"""; New = """name"": ""faktabandung-article-generator""" }
        )
        
        foreach ($replacement in $replacements) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $FileChanges["package_files"] += 1
            Write-Log -Message "Updated package.json: $($file.Name)"
        }
    } catch {
        Write-ErrorLog -Message "Error processing package.json $($file.FullName): $_"
    }
}

# 5. UPDATE DOCUMENTATION
Write-Log -Message "--- STEP 5: Updating documentation files ---"

$docFiles = @(
    "AUTOMATION_README.md",
    "GOOGLE_DRIVE_GUIDE.md",
    "GOOGLE_DRIVE_IMAGES_GUIDE.md",
    "netlify.toml",
    "PERBAIKAN_STATUS.md",
    "SEARCH_SETUP.md",
    "TROUBLESHOOTING.md"
)

foreach ($docFile in $docFiles) {
    $filePath = Join-Path $WorkspaceRoot $docFile
    if (Test-Path $filePath) {
        try {
            $content = Get-Content -Path $filePath -Raw -Encoding UTF8
            $originalContent = $content
            
            $replacements = @(
                @{ Old = "Fakta bandung"; New = "Fakta bandung" },
                @{ Old = "faktabandung"; New = "faktabandung" },
                @{ Old = "Fakta bandung"; New = "Fakta bandung" }
            )
            
            foreach ($replacement in $replacements) {
                $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
            }
            
            if ($content -ne $originalContent) {
                Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
                $FileChanges["docs"] += 1
                Write-Log -Message "Updated: $docFile"
            }
        } catch {
            Write-ErrorLog -Message "Error processing $docFile`: $_"
        }
    }
}

# 6. VERIFY NO OLD BRANDING REMAINS
Write-Log -Message "--- STEP 6: Verification ---"

$searchPatterns = @("Fakta bandung", "faktabandung", "Fakta bandung")
$foundIssues = @()

foreach ($pattern in $searchPatterns) {
    $results = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.css", "*.json", "*.md", "*.toml" -File |
        Select-String -Pattern $pattern -ErrorAction SilentlyContinue

    foreach ($result in $results) {
        if ($result.Path -notlike "*\archive\*" -and $result.Path -notlike "*\.bak.*") {
            $foundIssues += @{
                File = $result.Path
                Pattern = $pattern
                Line = $result.LineNumber
                Content = $result.Line
            }
        }
    }
}

# 7. VERIFY NEW COLORS ARE USED
Write-Log -Message "--- Verifying new color scheme ---"

$newColors = @("#2563EB", "#1E293B", "#5C3D1A")
$colorFound = @{}

foreach ($color in $newColors) {
    $cssResults = Get-ChildItem -Path (Join-Path $WorkspaceRoot "css") -Include "*.css" -File |
        Select-String -Pattern $color -ErrorAction SilentlyContinue
    $colorFound[$color] = $cssResults.Count -gt 0
}

# 8. SUMMARY
Write-Log -Message ""
Write-Log -Message "===== REBRAND SUMMARY ====="
Write-Log -Message "Main pages updated: $($FileChanges['main_pages'])"
Write-Log -Message "Article pages updated: $($FileChanges['article_pages'])"
Write-Log -Message "CSS files updated: $($FileChanges['css_files'])"
Write-Log -Message "Package files updated: $($FileChanges['package_files'])"
Write-Log -Message "Documentation updated: $($FileChanges['docs'])"

if ($foundIssues.Count -gt 0) {
    Write-Log -Message ""
    Write-Log -Message "⚠️  WARNING: Found $($foundIssues.Count) potential old branding references:" -Type "WARNING"
    foreach ($issue in $foundIssues | Select-Object -First 10) {
        Write-Log -Message "  - File: $($issue.File), Line $($issue.Line): $($issue.Pattern)" -Type "WARNING"
    }
    if ($foundIssues.Count -gt 10) {
        Write-Log -Message "  ... and $($foundIssues.Count - 10) more" -Type "WARNING"
    }
} else {
    Write-Log -Message "✅ No old branding references found!"
}

Write-Log -Message ""
Write-Log -Message "Color scheme verification:"
foreach ($color in $newColors) {
    $status = if ($colorFound[$color]) { "✅ Found" } else { "⚠️  Not found" }
    Write-Log -Message "  $($color): $status"
}

if ($ErrorLog.Count -gt 0) {
    Write-Log -Message ""
    Write-Log -Message "❌ ERRORS ENCOUNTERED:" -Type "ERROR"
    foreach ($error in $ErrorLog) {
        Write-Log -Message "  - $error" -Type "ERROR"
    }
}

Write-Log -Message ""
Write-Log -Message "Rebrand Fakta bandung selesai ✅"
Write-Log -Message "Report saved to: $LogFile"
Write-Log -Message "============================="

# Return summary for display
@{
    MainPages = $FileChanges["main_pages"]
    ArticlePages = $FileChanges["article_pages"]
    CSSFiles = $FileChanges["css_files"]
    PackageFiles = $FileChanges["package_files"]
    Docs = $FileChanges["docs"]
    TotalFiles = ($FileChanges.Values | Measure-Object -Sum).Sum
    Issues = $foundIssues.Count
    LogFile = $LogFile
}
