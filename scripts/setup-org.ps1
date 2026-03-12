# =========================
# GITHUB ORG MASTER SETUP
# =========================
$Org = "rfloweroflife-ui"
$BaseDir = "$HOME\GitHub\$Org"

Write-Host "=== Step 1: Ensure GitHub CLI is installed ==="
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI not found. Installing with winget..."
    winget install --id GitHub.cli -e --source winget
    $env:Path += ";$env:ProgramFiles\GitHub CLI"
}

Write-Host "=== Step 2: Authenticate GitHub CLI ==="
try {
    gh auth status | Out-Null
    Write-Host "GitHub CLI already authenticated."
} catch {
    gh auth login --web --git-protocol https
}

Write-Host "=== Step 3: Show authenticated user ==="
$Me = gh api user --jq .login
Write-Host "Authenticated as: $Me"

Write-Host "=== Step 4: List organizations for this account ==="
gh org list --limit 200

Write-Host "=== Step 5: Verify access to target org ==="
try {
    $MembershipRole = gh api "/user/memberships/orgs/$Org" --jq .role
    Write-Host "Your current role in $Org is: $MembershipRole"
} catch {
    Write-Host "Could not confirm membership in $Org. Make sure this account belongs to the org."
    throw
}

Write-Host "=== Step 6: Create local folder ==="
New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null
Set-Location $BaseDir

Write-Host "=== Step 7: Pull full repo list from org ==="
$Repos = gh repo list $Org --limit 1000 --json name,nameWithOwner,isPrivate,isArchived,visibility,viewerPermission --jq '.[]'
if (-not $Repos) {
    Write-Host "No repositories found in $Org."
    exit
}

$RepoObjects = $Repos | ForEach-Object { $_ | ConvertFrom-Json }

Write-Host "=== Step 8: Clone every repo locally if not already cloned ==="
foreach ($repo in $RepoObjects) {
    $localPath = Join-Path $BaseDir $repo.name
    if (-not (Test-Path $localPath)) {
        Write-Host "Cloning $($repo.nameWithOwner)..."
        gh repo clone $repo.nameWithOwner $repo.name
    } else {
        Write-Host "Already cloned: $($repo.name)"
    }
}

Write-Host "=== Step 9: Make every repo private ==="
foreach ($repo in $RepoObjects) {
    if ($repo.visibility -ne "PRIVATE") {
        Write-Host "Changing $($repo.nameWithOwner) -> private"
        gh repo edit $repo.nameWithOwner --visibility private --accept-visibility-change-consequences
    } else {
        Write-Host "Already private: $($repo.nameWithOwner)"
    }
}

Write-Host "=== Step 10: Refresh and confirm visibility ==="
gh repo list $Org --limit 1000 --json name,visibility --jq '.[] | "\(.name) - \(.visibility)"'

Write-Host "=== Step 11: Check whether you are org owner ==="
$RoleNow = gh api "/user/memberships/orgs/$Org" --jq .role
Write-Host "Current org role: $RoleNow"

if ($RoleNow -ne "admin") {
    Write-Host "=== Step 12: Attempt to promote $Me to org owner/admin ==="
    Write-Host "This only succeeds if the authenticated account already has owner-level permission."
    try {
        gh api `
          --method PUT `
          -H "Accept: application/vnd.github+json" `
          "/orgs/$Org/memberships/$Me" `
          -f role=admin

        $RoleAfter = gh api "/user/memberships/orgs/$Org" --jq .role
        Write-Host "Updated org role: $RoleAfter"
    } catch {
        Write-Host "Could not promote account automatically."
        Write-Host "Reason: only an existing organization owner can make a user an org owner."
    }
} else {
    Write-Host "You are already an org owner/admin in $Org."
}

Write-Host "=== DONE ==="
Write-Host "Local clone folder: $BaseDir"
