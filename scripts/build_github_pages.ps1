# Build Flutter Web and copy to docs/ for GitHub Pages (branch: main, folder: /docs).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

Set-Location $Root

flutter pub get
flutter build web --base-href=/russian_vocabulary_quiz/

$docs = Join-Path $Root "docs"
if (Test-Path $docs) {
    Remove-Item -Recurse -Force $docs
}
New-Item -ItemType Directory -Path $docs | Out-Null
Copy-Item -Recurse -Force (Join-Path $Root "build\web\*") $docs
New-Item -ItemType File -Path (Join-Path $docs ".nojekyll") -Force | Out-Null

Write-Host "Done. Commit docs/ and push. Pages URL: https://<username>.github.io/russian_vocabulary_quiz/"
