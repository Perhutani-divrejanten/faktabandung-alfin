# Rebrand script for Fakta Bandung
# Backup articles.json
Copy-Item -Path "articles.json" -Destination "articles.json.bak.$(Get-Date -Format 'yyyyMMddHHmmss')" -Force

# Function to replace in files
function Replace-InFile {
    param (
        [string]$FilePath,
        [string]$OldString,
        [string]$NewString
    )
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $newContent = $content -replace [regex]::Escape($OldString), $NewString
    Set-Content -Path $FilePath -Value $newContent -Encoding UTF8
}

# Get all HTML files
$htmlFiles = Get-ChildItem -Recurse -Include *.html

# Branding changes
$replacements = @(
    @{Old="Indonesia Daily"; New="Fakta bandung"},
    @{Old="indonesiadaily"; New="faktabandung"},
    @{Old="IndonesiaDaily"; New="FaktaBandung"},
    @{Old="indonesiadaily@gmail.com"; New="faktabandung@gmail.com"},
    @{Old="indonesiadaily"; New="faktabandung"},  # social handles
    @{Old="- Indonesia Daily"; New="- Fakta bandung"},
    @{Old="Indonesia Daily"; New="Fakta bandung"}  # meta/title/footer
)

foreach ($file in $htmlFiles) {
    foreach ($rep in $replacements) {
        Replace-InFile -FilePath $file.FullName -OldString $rep.Old -NewString $rep.New
    }
    # Fix encoding
    Replace-InFile -FilePath $file.FullName -OldString "â€œ" -NewString '"'
    Replace-InFile -FilePath $file.FullName -OldString "â€" -NewString '"'
    Replace-InFile -FilePath $file.FullName -OldString "â€˜" -NewString "'"
    Replace-InFile -FilePath $file.FullName -OldString "â€™" -NewString "'"
    Replace-InFile -FilePath $file.FullName -OldString "â€“" -NewString "-"
    Replace-InFile -FilePath $file.FullName -OldString "â€”" -NewString "-"
    Replace-InFile -FilePath $file.FullName -OldString "Â" -NewString " "  # nbsp or U+FFFD
    # Remove logo.png references
    Replace-InFile -FilePath $file.FullName -OldString 'img src="../img/logo.png"' -NewString ''
    Replace-InFile -FilePath $file.FullName -OldString 'alt="logo"' -NewString 'alt="FaktaBandung"'
    # Update navbar-brand to text logo
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $content = $content -replace '<a class="navbar-brand">.*?</a>', '<a class="navbar-brand"><span style="font-weight: bold; color: #2563EB;">FAKTA</span> <span style="font-size: smaller; color: #5C3D1A;">BANDUNG</span></a>'
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

# CSS changes
$cssFiles = Get-ChildItem -Recurse -Include *.css
foreach ($file in $cssFiles) {
    Replace-InFile -FilePath $file.FullName -OldString "--primary:.*?" -NewString "--primary: #2563EB"
    Replace-InFile -FilePath $file.FullName -OldString "--dark:.*?" -NewString "--dark: #1E293B"
    Replace-InFile -FilePath $file.FullName -OldString "--secondary:.*?" -NewString "--secondary: #5C3D1A"
    # Update inline colors
    Replace-InFile -FilePath $file.FullName -OldString "#FFCC00" -NewString "#2563EB"
    Replace-InFile -FilePath $file.FullName -OldString "#1E2024" -NewString "#1E293B"
}

# Package.json
$packageFiles = Get-ChildItem -Include package.json -Recurse
foreach ($file in $packageFiles) {
    Replace-InFile -FilePath $file.FullName -OldString '"name": ".*?"' -NewString '"name": "faktabandung"'
    Replace-InFile -FilePath $file.FullName -OldString '"name": ".*?-article-generator"' -NewString '"name": "faktabandung-article-generator"'
}

# Docs
$docFiles = Get-ChildItem -Include *.md, netlify.toml -Recurse
foreach ($file in $docFiles) {
    foreach ($rep in $replacements) {
        Replace-InFile -FilePath $file.FullName -OldString $rep.Old -NewString $rep.New
    }
}

# Count changes
$mainPages = ($htmlFiles | Where-Object { $_.Directory.Name -ne "article" }).Count
$articlePages = ($htmlFiles | Where-Object { $_.Directory.Name -eq "article" }).Count
$cssCount = $cssFiles.Count
$packageCount = $packageFiles.Count
$docsCount = $docFiles.Count

Write-Host "Rebrand completed:"
Write-Host "Main pages changed: $mainPages"
Write-Host "Article pages changed: $articlePages"
Write-Host "CSS files changed: $cssCount"
Write-Host "Package files changed: $packageCount"
Write-Host "Docs changed: $docsCount"
Write-Host "Rebrand Fakta bandung selesai ✅"