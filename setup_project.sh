#!/usr/bin/env bash
# setup_project.sh - Automated Project Bootstrapper for Attendance Tracker
# Author: Leslie Mugiraneza
# Version: 2.0 (Enhanced Edition)

# ============================================================
# COLORS - Makes output easier to read
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color (reset)

# ============================================================
# LOGGING SETUP
# Every action gets written to a log file with a timestamp
# ============================================================
LOG_FILE="setup_log.txt"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ============================================================
# PRINT HELPERS
# ============================================================
print_success() { echo -e "${GREEN}[✔] $1${NC}"; log "SUCCESS: $1"; }
print_warning() { echo -e "${YELLOW}[⚠] $1${NC}"; log "WARNING: $1"; }
print_error()   { echo -e "${RED}[✘] $1${NC}"; log "ERROR: $1"; }
print_info()    { echo -e "${CYAN}[ℹ] $1${NC}"; log "INFO: $1"; }
print_step()    { echo -e "${BOLD}${BLUE}\n▶ $1${NC}"; log "STEP: $1"; }

# ============================================================
# PROGRESS BAR
# Shows a visual loading bar as the script runs
# ============================================================
progress_bar() {
    local duration=$1
    local steps=20
    local sleep_time
    sleep_time=$(echo "scale=2; $duration / $steps" | bc)
    echo -ne "${CYAN}["
    for ((i=0; i<steps; i++)); do
        echo -ne "█"
        sleep "$sleep_time"
    done
    echo -e "]${NC}"
}

# ============================================================
# BANNER - Printed when the script starts
# ============================================================
print_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║     ATTENDANCE TRACKER PROJECT BOOTSTRAPPER      ║"
    echo "║              Automated Setup v2.0                ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================
# SIGNAL TRAP - Handles Ctrl+C (SIGINT)
# If the user cancels mid-setup, this function runs instead
# of just stopping. It archives what was created and cleans up.
# ============================================================
cleanup_on_interrupt() {
    echo ""
    print_warning "Script interrupted by user!"
    log "INTERRUPTED: User pressed Ctrl+C"

    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        print_info "Archiving incomplete project..."
        ARCHIVE_NAME="${PROJECT_DIR}_archive"
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR" 2>/dev/null
        if [ -f "${ARCHIVE_NAME}.tar.gz" ]; then
            print_success "Archive created: ${ARCHIVE_NAME}.tar.gz"
            log "Archive created: ${ARCHIVE_NAME}.tar.gz"
        fi
        rm -rf "$PROJECT_DIR"
        print_info "Incomplete directory removed. Workspace is clean."
        log "Removed incomplete directory: $PROJECT_DIR"
    fi

    echo -e "${YELLOW}Setup was cancelled. Goodbye!${NC}"
    exit 1
}

# Register the trap - this listens for Ctrl+C
trap cleanup_on_interrupt SIGINT

# ============================================================
# HEALTH CHECK - Verifies required tools are installed
# ============================================================
health_check() {
    print_step "Running Environment Health Check"
    local all_ok=true

    # Check python3
    if python3 --version &>/dev/null; then
        PY_VERSION=$(python3 --version 2>&1)
        print_success "Python3 found: $PY_VERSION"
    else
        print_warning "Python3 is NOT installed. The attendance_checker.py will not run."
        all_ok=false
    fi

    # Check bc (used for progress bar math)
    if command -v bc &>/dev/null; then
        print_success "bc (calculator) found"
    else
        print_warning "bc not found. Progress bar will be skipped."
    fi

    # Check tar (used for archiving)
    if command -v tar &>/dev/null; then
        print_success "tar found - archiving feature available"
    else
        print_warning "tar not found. Archive feature will not work."
    fi

    if [ "$all_ok" = true ]; then
        print_success "All health checks passed!"
    else
        print_warning "Some tools are missing but setup will continue."
    fi
}

# ============================================================
# DUPLICATE CHECK
# Checks if a project with that name already exists
# ============================================================
duplicate_check() {
    if [ -d "$PROJECT_DIR" ]; then
        echo -e "${YELLOW}"
        echo "⚠ A project named '$PROJECT_DIR' already exists!"
        echo -e "${NC}"
        read -rp "What would you like to do? [o]verwrite / [r]ename / [c]ancel: " choice
        case "$choice" in
            o|O)
                rm -rf "$PROJECT_DIR"
                print_info "Old project removed. Starting fresh."
                log "Removed existing project: $PROJECT_DIR"
                ;;
            r|R)
                read -rp "Enter a new project name suffix: " new_suffix
                PROJECT_DIR="attendance_tracker_${new_suffix}"
                print_info "New project name: $PROJECT_DIR"
                log "Renamed project to: $PROJECT_DIR"
                ;;
            *)
                print_info "Setup cancelled by user."
                exit 0
                ;;
        esac
    fi
}

# ============================================================
# BUILD DIRECTORY STRUCTURE
# Creates all folders and files needed
# ============================================================
build_structure() {
    print_step "Building Directory Structure"

    mkdir -p "$PROJECT_DIR/Helpers"
    mkdir -p "$PROJECT_DIR/reports"
    touch "$PROJECT_DIR/attendance_checker.py"
    touch "$PROJECT_DIR/Helpers/assets.csv"
    touch "$PROJECT_DIR/Helpers/config.json"
    touch "$PROJECT_DIR/reports/reports.log"

    print_success "Directory structure created"
    log "Created directory structure for: $PROJECT_DIR"
}

# ============================================================
# POPULATE FILES
# Copies the source files into the project directory
# ============================================================
populate_files() {
    print_step "Populating Source Files"

    # Get the directory where this script lives
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Copy attendance_checker.py
    if [ -f "$SCRIPT_DIR/attendance_checker.py" ]; then
        cp "$SCRIPT_DIR/attendance_checker.py" "$PROJECT_DIR/attendance_checker.py"
        print_success "attendance_checker.py copied"
    else
        print_warning "attendance_checker.py not found in script directory. Creating placeholder."
        echo "# attendance_checker.py - Add your source code here" > "$PROJECT_DIR/attendance_checker.py"
    fi

    # Copy assets.csv
    if [ -f "$SCRIPT_DIR/assets.csv" ]; then
        cp "$SCRIPT_DIR/assets.csv" "$PROJECT_DIR/Helpers/assets.csv"
        print_success "assets.csv copied"
    else
        print_warning "assets.csv not found. Creating sample data."
        cat > "$PROJECT_DIR/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
    fi

    # Copy reports.log
    if [ -f "$SCRIPT_DIR/reports.log" ]; then
        cp "$SCRIPT_DIR/reports.log" "$PROJECT_DIR/reports/reports.log"
        print_success "reports.log copied"
    else
        echo "--- Attendance Report Log ---" > "$PROJECT_DIR/reports/reports.log"
        print_info "Created empty reports.log"
    fi

    # Create config.json with default values
    cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
    print_success "config.json created with default values"
    log "All source files populated"
}

# ============================================================
# CONFIGURE THRESHOLDS USING SED
# Asks the user if they want to change the warning/failure %
# sed does an "in-place" edit of the config.json file
# ============================================================
configure_thresholds() {
    print_step "Configuring Attendance Thresholds"

    echo -e "${CYAN}Current default thresholds:${NC}"
    echo "  Warning threshold:  75%"
    echo "  Failure threshold:  50%"
    echo ""

    read -rp "Would you like to update these thresholds? (y/n): " update_choice

    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # Get new warning threshold
        read -rp "Enter new Warning threshold % (default 75): " new_warning
        new_warning="${new_warning:-75}"

        # Get new failure threshold
        read -rp "Enter new Failure threshold % (default 50): " new_failure
        new_failure="${new_failure:-50}"

        # Validate that warning is higher than failure
        if [ "$new_warning" -le "$new_failure" ]; then
            print_warning "Warning threshold must be higher than failure threshold!"
            print_info "Using defaults: warning=75, failure=50"
            new_warning=75
            new_failure=50
        fi

        # Use sed to update the values in config.json
        # sed -i means edit the file in-place (directly)
        sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" "$PROJECT_DIR/Helpers/config.json"
        sed -i "s/\"failure\": [0-9]*/\"failure\": $new_failure/" "$PROJECT_DIR/Helpers/config.json"

        print_success "Thresholds updated: Warning=$new_warning%, Failure=$new_failure%"
        log "Thresholds updated: warning=$new_warning, failure=$new_failure"
    else
        print_info "Keeping default thresholds (warning=75%, failure=50%)"
        log "Default thresholds kept"
    fi
}

# ============================================================
# EXTRA FEATURE: RUN MODE CONFIGURATION
# Asks the user if they want live or dry-run mode
# ============================================================
configure_run_mode() {
    print_step "Configuring Run Mode"

    echo -e "${CYAN}Available run modes:${NC}"
    echo "  live    - Sends real alerts and writes to log"
    echo "  dry_run - Simulates without writing anything"
    echo ""

    read -rp "Select run mode [live/dry_run] (default: live): " run_mode
    run_mode="${run_mode:-live}"

    if [[ "$run_mode" != "live" && "$run_mode" != "dry_run" ]]; then
        print_warning "Invalid mode. Using default: live"
        run_mode="live"
    fi

    sed -i "s/\"run_mode\": \"[^\"]*\"/\"run_mode\": \"$run_mode\"/" "$PROJECT_DIR/Helpers/config.json"
    print_success "Run mode set to: $run_mode"
    log "Run mode configured: $run_mode"
}

# ============================================================
# EXTRA FEATURE: AUTO GIT INIT
# Initializes a git repository inside the project folder
# ============================================================
auto_git_init() {
    print_step "Initializing Git Repository"

    read -rp "Would you like to initialize a git repository? (y/n): " git_choice

    if [[ "$git_choice" =~ ^[Yy]$ ]]; then
        cd "$PROJECT_DIR" || return
        git init &>/dev/null
        echo "reports/*.archive" > .gitignore
        echo "setup_log.txt" >> .gitignore
        echo "__pycache__/" >> .gitignore
        git add . &>/dev/null
        git commit -m "Initial project setup by setup_project.sh" &>/dev/null
        cd - > /dev/null || return
        print_success "Git repository initialized with initial commit"
        log "Git repository initialized in $PROJECT_DIR"
    else
        print_info "Skipping git initialization"
    fi
}

# ============================================================
# PRINT SUMMARY
# Shows a clean receipt of everything that was created
# ============================================================
print_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║              SETUP COMPLETE! ✔                   ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}Project Directory:${NC} $PROJECT_DIR"
    echo ""
    echo -e "${CYAN}Files Created:${NC}"
    find "$PROJECT_DIR" -type f | sort | while read -r file; do
        echo "  ✔ $file"
    done
    echo ""
    echo -e "${CYAN}To run the attendance checker:${NC}"
    echo "  cd $PROJECT_DIR && python3 attendance_checker.py"
    echo ""
    echo -e "${CYAN}Setup log saved to:${NC} $LOG_FILE"
    echo ""
    log "Setup completed successfully for: $PROJECT_DIR"
}

# ============================================================
# MAIN - This is where everything runs in order
# ============================================================
main() {
    print_banner

    # Start the log file
    echo "======================================" > "$LOG_FILE"
    echo "Setup started: $(date)" >> "$LOG_FILE"
    echo "======================================" >> "$LOG_FILE"

    # Step 1: Ask for project name
    print_step "Project Configuration"
    read -rp "Enter a project name suffix (e.g. v1, dev, prod): " project_input
    project_input="${project_input:-default}"
    PROJECT_DIR="attendance_tracker_${project_input}"
    print_info "Project will be created as: $PROJECT_DIR"
    log "Project name: $PROJECT_DIR"

    # Step 2: Check for duplicates
    duplicate_check

    # Step 3: Health check
    health_check

    # Step 4: Build structure
    echo ""
    print_info "Setting up project structure..."
    progress_bar 1
    build_structure

    # Step 5: Populate files
    populate_files

    # Step 6: Configure thresholds
    configure_thresholds

    # Step 7: Configure run mode (extra feature)
    configure_run_mode

    # Step 8: Auto git init (extra feature)
    auto_git_init

    # Step 9: Print summary
    print_summary
}

# Run main
main
