# AI Fluency 학습 허브 → GitHub 업로드 스크립트
# 더블클릭 실행용 — _push-to-github.bat이 이 파일을 호출합니다.

$ErrorActionPreference = 'Continue'
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = "G:\내 드라이브\태식\학교\2026\AI중점학교\claude_education"
$ghUser = "uts1368"
$repoName = "claude-education"
$repoUrl = "https://github.com/$ghUser/$repoName.git"

Set-Location $root

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  AI Fluency 학습 허브  →  GitHub Upload" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Target: $repoUrl"
Write-Host ""
Write-Host "  ※ GitHub.com에서 빈 리포를 먼저 만드셨나요?"
Write-Host "     - Repository name : $repoName"
Write-Host "     - Public"
Write-Host "     - README / .gitignore / license  →  모두 체크 해제"
Write-Host ""
Write-Host "  ※ 아직이면 새 창에서 만드세요:"
Write-Host "     https://github.com/new"
Write-Host ""
$null = Read-Host "  준비되었으면 [Enter] — 아니면 Ctrl+C로 종료"

# git 설치 확인
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  X  git이 설치되어 있지 않습니다." -ForegroundColor Red
    Write-Host "     Git for Windows: https://git-scm.com/download/win"
    Read-Host "  Enter로 종료"
    exit 1
}

# Step 1: site/index.html → 루트의 index.html
Write-Host ""
Write-Host "[1/6] Copy site\index.html -> index.html" -ForegroundColor Yellow
if (Test-Path "site\index.html") {
    Copy-Item "site\index.html" "index.html" -Force
    Write-Host "      OK" -ForegroundColor Green
} else {
    Write-Host "      X site\index.html not found" -ForegroundColor Red
    Read-Host "  Enter로 종료"
    exit 1
}

# Step 2: git user 정보
Write-Host ""
Write-Host "[2/6] Set git user info" -ForegroundColor Yellow
git config --global user.name "엄태식" 2>&1 | Out-Null
git config --global user.email "uts1368@dajeong.sjedues.kr" 2>&1 | Out-Null
Write-Host "      OK (엄태식 / uts1368@dajeong.sjedues.kr)" -ForegroundColor Green

# Step 3: git init
Write-Host ""
Write-Host "[3/6] Initialize git repo" -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init 2>&1 | Out-Null
    git branch -M main 2>&1 | Out-Null
    Write-Host "      OK (new)" -ForegroundColor Green
} else {
    git branch -M main 2>&1 | Out-Null
    Write-Host "      OK (already initialized)" -ForegroundColor Gray
}

# Step 4: add + commit
Write-Host ""
Write-Host "[4/6] Stage files + commit" -ForegroundColor Yellow
git add . 2>&1 | Out-Null
$status = git status --porcelain
if ($status) {
    git commit -m "AI Fluency 학습 허브 — 23차시 한국어 정리" 2>&1 | Out-Null
    $changed = ($status -split "`n").Count
    Write-Host "      OK ($changed files staged)" -ForegroundColor Green
} else {
    Write-Host "      OK (no changes — using existing commit)" -ForegroundColor Gray
}

# Step 5: remote
Write-Host ""
Write-Host "[5/6] Set remote origin" -ForegroundColor Yellow
git remote remove origin 2>&1 | Out-Null
git remote add origin $repoUrl
Write-Host "      OK ($repoUrl)" -ForegroundColor Green

# Step 6: push
Write-Host ""
Write-Host "[6/6] Push to GitHub" -ForegroundColor Yellow
Write-Host "      ※ 인증 창이 뜨면 GitHub 로그인 (1회만)" -ForegroundColor Gray
Write-Host ""
git push -u origin main
$pushOk = ($LASTEXITCODE -eq 0)

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
if ($pushOk) {
    Write-Host "  완료! 모두 GitHub에 올라갔습니다." -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  마지막 단계 — GitHub Pages 활성화 (30초):"
    Write-Host ""
    Write-Host "    1) 이 URL을 브라우저로 여세요:"
    Write-Host "       https://github.com/$ghUser/$repoName/settings/pages" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    2) Source = Deploy from a branch"
    Write-Host "    3) Branch = main  /  폴더 = / (root)"
    Write-Host "    4) Save 클릭"
    Write-Host ""
    Write-Host "  1~2분 뒤 사이트 공개 URL:"
    Write-Host "    https://$ghUser.github.io/$repoName/" -ForegroundColor Cyan
} else {
    Write-Host "  X  push 실패" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  가능한 원인:"
    Write-Host "   - GitHub에 빈 리포가 아직 안 만들어짐"
    Write-Host "       → https://github.com/new 에서 먼저 만드세요"
    Write-Host "   - 인증 창에서 취소함"
    Write-Host "       → 다시 더블클릭하면 인증 창이 또 뜹니다"
    Write-Host "   - 리포가 이미 있고 README 같은 파일을 포함해 만들어짐"
    Write-Host "       → 그 리포를 삭제하고 (Settings 맨 아래 Delete)"
    Write-Host "         초기화 옵션 모두 해제로 다시 만드세요"
    Write-Host ""
    Write-Host "  위 빨간 메시지를 Claude에게 그대로 보여주시면 도와드려요."
}
Write-Host ""
Read-Host "  Enter로 종료"
