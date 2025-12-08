#!/usr/bin/env pwsh
# Conventional Commits validation hook
# This hook validates commit messages according to https://www.conventionalcommits.org/

$commitMsgFile = $args[0]

try {
    $commitMsg = Get-Content $commitMsgFile -Raw -ErrorAction Stop
} catch {
    Write-Host "Error: Could not read commit message file" -ForegroundColor Red
    exit 1
}

# Remove comments and trim
$commitMsg = ($commitMsg -split "`n" | Where-Object { $_ -notmatch '^\s*#' }) -join "`n"
$commitMsg = $commitMsg.Trim()

if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    Write-Host "Error: Commit message is empty" -ForegroundColor Red
    exit 1
}

# Get the first line (subject)
$subject = ($commitMsg -split "`n")[0]

# Conventional Commits regex pattern
# Format: type(scope)!: description
# - type: required (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
# - scope: optional
# - !: optional (indicates breaking change)
# - description: required
$pattern = '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|deps)(\([a-z0-9\-\/]+\))?(!)?: \S.{0,}'

if ($subject -notmatch $pattern) {
    Write-Host ""
    Write-Host "❌ COMMIT REJECTED: Invalid commit message format" -ForegroundColor Red
    Write-Host ""
    Write-Host "Your commit message:" -ForegroundColor Yellow
    Write-Host "  $subject" -ForegroundColor White
    Write-Host ""
    Write-Host "Conventional Commits format required:" -ForegroundColor Cyan
    Write-Host "  <type>[optional scope][optional !]: <description>" -ForegroundColor White
    Write-Host ""
    Write-Host "Valid types:" -ForegroundColor Cyan
    Write-Host "  feat:     A new feature" -ForegroundColor White
    Write-Host "  fix:      A bug fix" -ForegroundColor White
    Write-Host "  docs:     Documentation only changes" -ForegroundColor White
    Write-Host "  style:    Code style changes (formatting, missing semicolons, etc.)" -ForegroundColor White
    Write-Host "  refactor: Code change that neither fixes a bug nor adds a feature" -ForegroundColor White
    Write-Host "  perf:     Performance improvements" -ForegroundColor White
    Write-Host "  test:     Adding or correcting tests" -ForegroundColor White
    Write-Host "  build:    Changes to build system or dependencies" -ForegroundColor White
    Write-Host "  ci:       Changes to CI configuration files and scripts" -ForegroundColor White
    Write-Host "  chore:    Other changes that don't modify src or test files" -ForegroundColor White
    Write-Host "  revert:   Reverts a previous commit" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  feat: add user authentication" -ForegroundColor Green
    Write-Host "  fix(api): resolve null reference exception" -ForegroundColor Green
    Write-Host "  feat(auth)!: change login flow (breaking change)" -ForegroundColor Green
    Write-Host "  docs: update README with setup instructions" -ForegroundColor Green
    Write-Host ""
    Write-Host "For more information, visit: https://www.conventionalcommits.org/" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Check subject length (recommended max 72 characters for subject)
if ($subject.Length -gt 72) {
    Write-Host ""
    Write-Host "⚠️  WARNING: Commit subject is longer than 72 characters ($($subject.Length) chars)" -ForegroundColor Yellow
    Write-Host "Consider shortening the description or moving details to the body." -ForegroundColor Yellow
    Write-Host ""
    # This is just a warning, not rejecting the commit
}

# Optional: Check for body format if breaking change indicator is present
if ($subject -match '!:' -or $commitMsg -match 'BREAKING CHANGE:') {
    if ($commitMsg -notmatch 'BREAKING CHANGE:') {
        Write-Host ""
        Write-Host "⚠️  WARNING: Breaking change indicator (!) found but no 'BREAKING CHANGE:' in body" -ForegroundColor Yellow
        Write-Host "Consider adding a 'BREAKING CHANGE: <description>' section in the commit body." -ForegroundColor Yellow
        Write-Host ""
        # This is just a warning, not rejecting the commit
    }
}

Write-Host "✅ Commit message follows Conventional Commits format" -ForegroundColor Green
exit 0
