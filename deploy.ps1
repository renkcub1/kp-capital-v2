param(
    [Parameter(Mandatory = $true)]
    [string]$Message
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$branch = git branch --show-current

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw "Could not identify the current Git branch."
}

Write-Host "Building the production website..." -ForegroundColor Cyan

npm run build

if ($LASTEXITCODE -ne 0) {
    throw "Production build failed. Nothing was saved or pushed."
}

if (-not (Test-Path ".\dist\index.html")) {
    throw "Production build did not create dist\index.html."
}

Write-Host "Saving changes to GitHub..." -ForegroundColor Cyan

git add -A

if ($LASTEXITCODE -ne 0) {
    throw "Could not stage the changes."
}

$stagedChanges = git diff --cached --name-only

if ($stagedChanges) {
    git commit -m $Message

    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed."
    }
}
else {
    Write-Host "No new code changes to commit." -ForegroundColor Yellow
}

git push origin $branch

if ($LASTEXITCODE -ne 0) {
    throw "GitHub push failed."
}

Write-Host ""
Write-Host "Build and GitHub push completed successfully." -ForegroundColor Green
Write-Host "No live server deployment is configured for this project." -ForegroundColor Yellow