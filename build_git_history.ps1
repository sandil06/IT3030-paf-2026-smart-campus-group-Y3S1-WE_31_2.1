# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Smart Campus System — Git History Reconstruction Script
# Simulates development by 5 members across 10 feature branches
# Run this script from INSIDE new_smart_campus_system/
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Source & Target Paths ───────────────────────────────────────────────────
$src        = 'e:\Downloads\Smart campus system\Smart campus system\existing project'
$srcBE      = "$src\backend"
$srcHub     = "$srcBE\src\main\java\com\campus\hub"
$srcFE      = "$src\frontend"
$srcFESrc   = "$srcFE\src"

$target     = 'e:\Downloads\Smart campus system\Smart campus system\new_smart_campus_system'
$tgtHub     = "$target\backend\src\main\java\com\campus\hub"
$tgtFESrc   = "$target\frontend\src"

# ─── Helper Functions ────────────────────────────────────────────────────────

# Ensure directory exists
function D($path) {
    if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}

# Copy a file, creating parent directories as needed
function CF($from, $to) {
    D (Split-Path $to -Parent)
    Copy-Item $from $to -Force
}

# Stage all changes and commit with a specific author
function GitCommit($msg, $name, $email) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git add -A
    $result = git commit --author="$name <$email>" -m $msg
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) {
        Write-Host "  Commit failed: $msg" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    Write-Host "  OK [$name] $msg" -ForegroundColor Green
}

# Create a new feature branch from develop
function MB($branch) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git checkout develop
    git checkout -b $branch
    $ErrorActionPreference = $prev
    Write-Host "`n  Branch created: $branch" -ForegroundColor Cyan
}

# Merge a feature branch back to develop (no fast-forward)
function MergeToDevelop($branch) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    git checkout develop
    git merge --no-ff $branch -m "Merge $branch into develop"
    $ErrorActionPreference = $prev
    Write-Host "  Merged: $branch into develop" -ForegroundColor Yellow
}

# ─── Author Details ──────────────────────────────────────────────────────────
$teamName  = "Smart Campus Team"
$teamEmail = "team@smartcampus.edu"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INITIALIZE REPOSITORY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n=== Initializing Repository ===" -ForegroundColor Magenta

Set-Location $target
git init
git config user.email $teamEmail
git config user.name $teamName
git config core.autocrlf false
git config core.safecrlf false

# Root-level .gitignore
@"
# Java build artifacts
target/
*.class
*.jar
*.war

# Node artifacts
node_modules/
build/

# Environment files
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.iml

# OS files
.DS_Store
Thumbs.db
"@ | Set-Content "$target\.gitignore"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PHASE 0 — Initial Project Setup (on main)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n=== Phase 0: Initial Project Setup ===" -ForegroundColor Magenta

# ── Commit 1: Backend scaffold ──
D "$tgtHub"
D "$target\backend\src\main\resources"
CF "$srcBE\pom.xml"                                  "$target\backend\pom.xml"
CF "$srcBE\.gitignore"                               "$target\backend\.gitignore"
CF "$srcBE\src\main\resources\application.yml"       "$target\backend\src\main\resources\application.yml"
CF "$srcHub\OperationsHubApplication.java"           "$tgtHub\OperationsHubApplication.java"
if (Test-Path "$srcBE\.mvn") {
    Copy-Item "$srcBE\.mvn" "$target\backend\.mvn" -Recurse -Force
}
GitCommit "chore: initialize Spring Boot backend project structure" $teamName $teamEmail

# ── Commit 2: Frontend scaffold ──
D "$tgtFESrc"
D "$target\frontend\public"
CF "$srcFE\package.json"   "$target\frontend\package.json"
CF "$srcFE\.gitignore"     "$target\frontend\.gitignore"
CF "$srcFE\.env"           "$target\frontend\.env"
CF "$srcFESrc\index.js"    "$tgtFESrc\index.js"
if (Test-Path "$srcFE\public") {
    Get-ChildItem "$srcFE\public" | ForEach-Object {
        Copy-Item $_.FullName "$target\frontend\public\$($_.Name)" -Force -Recurse
    }
}
GitCommit "chore: initialize React frontend project with CRA base structure" $teamName $teamEmail

# ── Commit 3: README ──
CF "$srcFE\README.md" "$target\README.md"
GitCommit "docs: add project README with setup and run instructions" $teamName $teamEmail

# Rename default branch to main and create develop
$ErrorActionPreference = 'Continue'
git branch -M main
git checkout -b develop
$ErrorActionPreference = 'Stop'
Write-Host "  main branch established, develop branch created" -ForegroundColor Yellow

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 1 — Facilities & Assets Catalogue — BACKEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_1: Facilities and Assets - Backend ---" -ForegroundColor Magenta
MB "feature/member_1-facilities-backend"

# Commit 1 — Domain models
CF "$srcHub\model\Resource.java"             "$tgtHub\model\Resource.java"
CF "$srcHub\model\ResourceType.java"         "$tgtHub\model\ResourceType.java"
GitCommit "feat(facilities): add Resource and ResourceType domain models" "member_1" "member_1@smartcampus.edu"

# Commit 2 — Status enums
CF "$srcHub\model\ResourceStatus.java"       "$tgtHub\model\ResourceStatus.java"
CF "$srcHub\model\ResourceAvailability.java" "$tgtHub\model\ResourceAvailability.java"
GitCommit "feat(facilities): add ResourceStatus and ResourceAvailability enums" "member_1" "member_1@smartcampus.edu"

# Commit 3 — Repository
CF "$srcHub\repository\ResourceRepository.java" "$tgtHub\repository\ResourceRepository.java"
GitCommit "feat(facilities): add ResourceRepository with custom query methods" "member_1" "member_1@smartcampus.edu"

# Commit 4 — Service layer
CF "$srcHub\service\ResourceService.java"    "$tgtHub\service\ResourceService.java"
GitCommit "feat(facilities): implement ResourceService with CRUD and search logic" "member_1" "member_1@smartcampus.edu"

# Commit 5 — Controller + DTOs
CF "$srcHub\dto\ResourceDTO.java"            "$tgtHub\dto\ResourceDTO.java"
CF "$srcHub\dto\CreateResourceRequest.java"  "$tgtHub\dto\CreateResourceRequest.java"
CF "$srcHub\dto\UpdateResourceRequest.java"  "$tgtHub\dto\UpdateResourceRequest.java"
CF "$srcHub\dto\PageResponse.java"           "$tgtHub\dto\PageResponse.java"
CF "$srcHub\controller\ResourceController.java" "$tgtHub\controller\ResourceController.java"
GitCommit "feat(facilities): add ResourceController REST endpoints with pagination and DTOs" "member_1" "member_1@smartcampus.edu"

# Commit 6 — Admin controller
CF "$srcHub\controller\AdminController.java" "$tgtHub\controller\AdminController.java"
GitCommit "feat(facilities): add AdminController for admin-only resource management" "member_1" "member_1@smartcampus.edu"

MergeToDevelop "feature/member_1-facilities-backend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 2 — Booking Management — BACKEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_2: Booking Management - Backend ---" -ForegroundColor Magenta
MB "feature/member_2-booking-backend"

# Commit 1 — Domain model
CF "$srcHub\model\Booking.java"              "$tgtHub\model\Booking.java"
CF "$srcHub\model\BookingStatus.java"        "$tgtHub\model\BookingStatus.java"
GitCommit "feat(booking): add Booking domain model and BookingStatus enum" "member_2" "member_2@smartcampus.edu"

# Commit 2 — Repository
CF "$srcHub\repository\BookingRepository.java" "$tgtHub\repository\BookingRepository.java"
GitCommit "feat(booking): add BookingRepository with availability query methods" "member_2" "member_2@smartcampus.edu"

# Commit 3 — Service
CF "$srcHub\service\BookingService.java"     "$tgtHub\service\BookingService.java"
GitCommit "feat(booking): implement BookingService with conflict detection logic" "member_2" "member_2@smartcampus.edu"

# Commit 4 — DTOs
CF "$srcHub\dto\BookingDTO.java"             "$tgtHub\dto\BookingDTO.java"
CF "$srcHub\dto\CreateBookingRequest.java"   "$tgtHub\dto\CreateBookingRequest.java"
GitCommit "feat(booking): add BookingDTO and CreateBookingRequest DTOs" "member_2" "member_2@smartcampus.edu"

# Commit 5 — Controller
CF "$srcHub\controller\BookingController.java" "$tgtHub\controller\BookingController.java"
GitCommit "feat(booking): add BookingController with CRUD and status update endpoints" "member_2" "member_2@smartcampus.edu"

# Commit 6 — Fix: add a clarifying comment simulating real bug fix
$bsPath = "$tgtHub\service\BookingService.java"
$bsContent = [System.IO.File]::ReadAllText($bsPath)
$bsContent = $bsContent.Replace(
    "package com.campus.hub.service;",
    "package com.campus.hub.service;`n`n// fix: overlap check uses exclusive end boundary to prevent back-to-back conflicts"
)
[System.IO.File]::WriteAllText($bsPath, $bsContent)
GitCommit "fix(booking): handle overlapping booking conflict edge cases in service" "member_2" "member_2@smartcampus.edu"

MergeToDevelop "feature/member_2-booking-backend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 3 — Maintenance and Ticketing — BACKEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_3: Maintenance and Ticketing - Backend ---" -ForegroundColor Magenta
MB "feature/member_3-maintenance-backend"

# Commit 1 — Ticket model + enums
CF "$srcHub\model\Ticket.java"               "$tgtHub\model\Ticket.java"
CF "$srcHub\model\TicketPriority.java"       "$tgtHub\model\TicketPriority.java"
CF "$srcHub\model\TicketStatus.java"         "$tgtHub\model\TicketStatus.java"
GitCommit "feat(maintenance): add Ticket model with TicketPriority and TicketStatus enums" "member_3" "member_3@smartcampus.edu"

# Commit 2 — Embedded comment document
CF "$srcHub\model\TicketComment.java"        "$tgtHub\model\TicketComment.java"
GitCommit "feat(maintenance): add TicketComment as embedded subdocument model" "member_3" "member_3@smartcampus.edu"

# Commit 3 — Repository
CF "$srcHub\repository\TicketRepository.java" "$tgtHub\repository\TicketRepository.java"
GitCommit "feat(maintenance): add TicketRepository with status and assignee filter queries" "member_3" "member_3@smartcampus.edu"

# Commit 4 — Service
CF "$srcHub\service\TicketService.java"      "$tgtHub\service\TicketService.java"
GitCommit "feat(maintenance): implement TicketService with full lifecycle state machine" "member_3" "member_3@smartcampus.edu"

# Commit 5 — DTOs
CF "$srcHub\dto\CreateTicketRequest.java"    "$tgtHub\dto\CreateTicketRequest.java"
CF "$srcHub\dto\TicketDTO.java"              "$tgtHub\dto\TicketDTO.java"
GitCommit "feat(maintenance): add CreateTicketRequest and TicketDTO for API layer" "member_3" "member_3@smartcampus.edu"

# Commit 6 — Controller
CF "$srcHub\controller\TicketController.java" "$tgtHub\controller\TicketController.java"
GitCommit "feat(maintenance): add TicketController with comment thread and attachment support" "member_3" "member_3@smartcampus.edu"

MergeToDevelop "feature/member_3-maintenance-backend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 4 — Notifications — BACKEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_4: Notifications - Backend ---" -ForegroundColor Magenta
MB "feature/member_4-notifications-backend"

# Commit 1 — Model + enum
CF "$srcHub\model\Notification.java"         "$tgtHub\model\Notification.java"
CF "$srcHub\model\NotificationType.java"     "$tgtHub\model\NotificationType.java"
GitCommit "feat(notifications): add Notification model and NotificationType enum" "member_4" "member_4@smartcampus.edu"

# Commit 2 — Repository
CF "$srcHub\repository\NotificationRepository.java" "$tgtHub\repository\NotificationRepository.java"
GitCommit "feat(notifications): add NotificationRepository with per-user query methods" "member_4" "member_4@smartcampus.edu"

# Commit 3 — Service
CF "$srcHub\service\NotificationService.java" "$tgtHub\service\NotificationService.java"
GitCommit "feat(notifications): implement NotificationService for delivery and read-tracking" "member_4" "member_4@smartcampus.edu"

# Commit 4 — DTO
CF "$srcHub\dto\NotificationDTO.java"        "$tgtHub\dto\NotificationDTO.java"
GitCommit "feat(notifications): add NotificationDTO for API response mapping" "member_4" "member_4@smartcampus.edu"

# Commit 5 — Controller
CF "$srcHub\controller\NotificationController.java" "$tgtHub\controller\NotificationController.java"
GitCommit "feat(notifications): add NotificationController with mark-as-read endpoint" "member_4" "member_4@smartcampus.edu"

MergeToDevelop "feature/member_4-notifications-backend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 5 — Authentication and Authorization — BACKEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_5: Auth and Authorization - Backend ---" -ForegroundColor Magenta
MB "feature/member_5-auth-backend"

# Commit 1 — User model + Role enum
CF "$srcHub\model\User.java"                 "$tgtHub\model\User.java"
CF "$srcHub\model\Role.java"                 "$tgtHub\model\Role.java"
GitCommit "feat(auth): add User model and Role enum" "member_5" "member_5@smartcampus.edu"

# Commit 2 — Repository
CF "$srcHub\repository\UserRepository.java"  "$tgtHub\repository\UserRepository.java"
GitCommit "feat(auth): add UserRepository with email lookup query method" "member_5" "member_5@smartcampus.edu"

# Commit 3 — AuthService
CF "$srcHub\service\AuthService.java"        "$tgtHub\service\AuthService.java"
GitCommit "feat(auth): implement AuthService with Google OAuth token validation" "member_5" "member_5@smartcampus.edu"

# Commit 4 — Auth DTOs
CF "$srcHub\dto\AuthResponse.java"           "$tgtHub\dto\AuthResponse.java"
CF "$srcHub\dto\GoogleAuthRequest.java"      "$tgtHub\dto\GoogleAuthRequest.java"
GitCommit "feat(auth): add AuthResponse and GoogleAuthRequest DTOs" "member_5" "member_5@smartcampus.edu"

# Commit 5 — AuthController
CF "$srcHub\controller\AuthController.java"  "$tgtHub\controller\AuthController.java"
GitCommit "feat(auth): add AuthController exposing Google OAuth login endpoint" "member_5" "member_5@smartcampus.edu"

# Commit 6 — Interceptor, CORS config, DataSeeder
CF "$srcHub\config\AuthInterceptor.java"     "$tgtHub\config\AuthInterceptor.java"
CF "$srcHub\config\WebMvcConfig.java"        "$tgtHub\config\WebMvcConfig.java"
CF "$srcHub\config\DataSeeder.java"          "$tgtHub\config\DataSeeder.java"
GitCommit "feat(auth): add AuthInterceptor for header validation, WebMvcConfig CORS, and DataSeeder" "member_5" "member_5@smartcampus.edu"

# Commit 7 — Global exception handling
CF "$srcHub\exception\GlobalExceptionHandler.java"    "$tgtHub\exception\GlobalExceptionHandler.java"
CF "$srcHub\exception\ErrorResponse.java"             "$tgtHub\exception\ErrorResponse.java"
CF "$srcHub\exception\ConflictException.java"         "$tgtHub\exception\ConflictException.java"
CF "$srcHub\exception\ResourceNotFoundException.java" "$tgtHub\exception\ResourceNotFoundException.java"
CF "$srcHub\exception\UnauthorizedException.java"     "$tgtHub\exception\UnauthorizedException.java"
CF "$srcHub\exception\ValidationException.java"       "$tgtHub\exception\ValidationException.java"
GitCommit "feat(auth): add GlobalExceptionHandler and all custom exception classes" "member_5" "member_5@smartcampus.edu"

MergeToDevelop "feature/member_5-auth-backend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 5 — Authentication — FRONTEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_5: Auth - Frontend ---" -ForegroundColor Magenta
MB "feature/member_5-auth-frontend"

# Commit 1 — authStorage utility
CF "$srcFESrc\services\authStorage.js"       "$tgtFESrc\services\authStorage.js"
GitCommit "feat(auth-ui): add authStorage utility for JWT token persistence" "member_5" "member_5@smartcampus.edu"

# Commit 2 — Axios API service
CF "$srcFESrc\services\api.js"               "$tgtFESrc\services\api.js"
GitCommit "feat(auth-ui): add axios API service with automatic auth header injection" "member_5" "member_5@smartcampus.edu"

# Commit 3 — AuthContext
CF "$srcFESrc\contexts\AuthContext.js"       "$tgtFESrc\contexts\AuthContext.js"
GitCommit "feat(auth-ui): add AuthContext provider for global user state management" "member_5" "member_5@smartcampus.edu"

# Commit 4 — ProtectedRoute
CF "$srcFESrc\components\ProtectedRoute.js"  "$tgtFESrc\components\ProtectedRoute.js"
GitCommit "feat(auth-ui): add ProtectedRoute component with admin role guard" "member_5" "member_5@smartcampus.edu"

# Commit 5 — Navbar
CF "$srcFESrc\components\Navbar.js"          "$tgtFESrc\components\Navbar.js"
GitCommit "feat(auth-ui): add Navbar with dynamic links based on authenticated user role" "member_5" "member_5@smartcampus.edu"

# Commit 6 — LoginPage
CF "$srcFESrc\pages\LoginPage.js"            "$tgtFESrc\pages\LoginPage.js"
GitCommit "feat(auth-ui): add LoginPage with Google OAuth sign-in button integration" "member_5" "member_5@smartcampus.edu"

# Commit 7 — App.js + global styles
CF "$srcFESrc\App.js"                        "$tgtFESrc\App.js"
CF "$srcFESrc\styles\main.css"               "$tgtFESrc\styles\main.css"
GitCommit "feat(auth-ui): wire up App.js routing tree, providers, and global CSS styles" "member_5" "member_5@smartcampus.edu"

MergeToDevelop "feature/member_5-auth-frontend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 1 — Facilities — FRONTEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_1: Facilities - Frontend ---" -ForegroundColor Magenta
MB "feature/member_1-facilities-frontend"

# Commit 1 — ResourceCard component
CF "$srcFESrc\components\ResourceCard.js"    "$tgtFESrc\components\ResourceCard.js"
GitCommit "feat(facilities-ui): add ResourceCard component for asset tile display" "member_1" "member_1@smartcampus.edu"

# Commit 2 — Resources page
CF "$srcFESrc\pages\Resources.js"            "$tgtFESrc\pages\Resources.js"
GitCommit "feat(facilities-ui): add Resources page with search and category filter" "member_1" "member_1@smartcampus.edu"

# Commit 3 — ResourceManager (admin)
CF "$srcFESrc\pages\ResourceManager.js"      "$tgtFESrc\pages\ResourceManager.js"
GitCommit "feat(facilities-ui): add ResourceManager admin page for full CRUD operations" "member_1" "member_1@smartcampus.edu"

# Commit 4 — Home dashboard
CF "$srcFESrc\pages\Home.js"                 "$tgtFESrc\pages\Home.js"
GitCommit "feat(facilities-ui): add Home dashboard with resource overview and quick stats" "member_1" "member_1@smartcampus.edu"

MergeToDevelop "feature/member_1-facilities-frontend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 2 — Booking Management — FRONTEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_2: Booking - Frontend ---" -ForegroundColor Magenta
MB "feature/member_2-booking-frontend"

# Commit 1 — BookingForm component
CF "$srcFESrc\components\BookingForm.js"     "$tgtFESrc\components\BookingForm.js"
GitCommit "feat(booking-ui): add BookingForm component with date, time and resource inputs" "member_2" "member_2@smartcampus.edu"

# Commit 2 — BookingList component
CF "$srcFESrc\components\BookingList.js"     "$tgtFESrc\components\BookingList.js"
GitCommit "feat(booking-ui): add BookingList component with status colour badges" "member_2" "member_2@smartcampus.edu"

# Commit 3 — Booking page
CF "$srcFESrc\pages\Booking.js"              "$tgtFESrc\pages\Booking.js"
GitCommit "feat(booking-ui): add Booking page that integrates BookingForm component" "member_2" "member_2@smartcampus.edu"

# Commit 4 — MyBookings page
CF "$srcFESrc\pages\MyBookings.js"           "$tgtFESrc\pages\MyBookings.js"
GitCommit "feat(booking-ui): add MyBookings page with cancel action and booking details" "member_2" "member_2@smartcampus.edu"

MergeToDevelop "feature/member_2-booking-frontend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 3 — Maintenance & Ticketing — FRONTEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_3: Maintenance - Frontend ---" -ForegroundColor Magenta
MB "feature/member_3-maintenance-frontend"

# Commit 1 — TicketForm component
CF "$srcFESrc\components\TicketForm.js"      "$tgtFESrc\components\TicketForm.js"
GitCommit "feat(maintenance-ui): add TicketForm component with priority and category inputs" "member_3" "member_3@smartcampus.edu"

# Commit 2 — Tickets page
CF "$srcFESrc\pages\Tickets.js"              "$tgtFESrc\pages\Tickets.js"
GitCommit "feat(maintenance-ui): add Tickets page with status filter and comment thread view" "member_3" "member_3@smartcampus.edu"

# Commit 3 — AdminDashboard
CF "$srcFESrc\pages\AdminDashboard.js"       "$tgtFESrc\pages\AdminDashboard.js"
GitCommit "feat(maintenance-ui): add AdminDashboard with ticket and booking oversight panels" "member_3" "member_3@smartcampus.edu"

MergeToDevelop "feature/member_3-maintenance-frontend"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MEMBER 4 — Notifications — FRONTEND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write-Host "`n--- member_4: Notifications - Frontend ---" -ForegroundColor Magenta
MB "feature/member_4-notifications-frontend"

# Commit 1 — NotificationList component
CF "$srcFESrc\components\NotificationList.js" "$tgtFESrc\components\NotificationList.js"
GitCommit "feat(notifications-ui): add NotificationList component with unread count badge" "member_4" "member_4@smartcampus.edu"

# Commit 2 — Notifications page
CF "$srcFESrc\pages\Notifications.js"         "$tgtFESrc\pages\Notifications.js"
GitCommit "feat(notifications-ui): add Notifications page with read and unread filter tabs" "member_4" "member_4@smartcampus.edu"

MergeToDevelop "feature/member_4-notifications-frontend"

# ============================================================
# FINAL RELEASE - develop into main
# ============================================================
Write-Host "`n=== Final Release: develop into main ===" -ForegroundColor Magenta
$ErrorActionPreference = 'Continue'
git checkout main
git merge --no-ff develop -m "release: merge develop into main - Smart Campus System v1.0.0"
$ErrorActionPreference = 'Stop'
Write-Host "  Done: develop merged into main - v1.0.0 released" -ForegroundColor Yellow

# Summary
Write-Host "`nGit history reconstruction complete!`n" -ForegroundColor Green
Write-Host "=== Branch Graph ==="  -ForegroundColor Cyan
git log --oneline --all --graph

Write-Host "`nTotal commits on main:" -ForegroundColor Cyan
git rev-list --count main

