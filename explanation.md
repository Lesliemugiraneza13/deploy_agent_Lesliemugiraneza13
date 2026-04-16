#This is a simple explanation for me to remember or use as reference in the future
# EXPLANATION.md
# How setup_project.sh Works — A Complete Breakdown

---

## What This Script Does Overall

This script is a "Project Factory". You run it once, answer a few questions, and it
builds an entire organized project folder for the Attendance Tracker automatically.
Instead of creating folders and files manually one by one, the script does everything
in seconds.

---

## The Structure of the Script

The script is organized into functions. Think of each function like a worker on an
assembly line. Each one has one specific job and they all get called in order at the end
inside the main() function.

---

## Every Part Explained Simply

---

### 1. Colors and Print Helpers

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
```

These are ANSI color codes. They make the terminal output colorful.
- Green = success
- Yellow = warning
- Red = error
- Cyan = information

The print_success, print_warning, print_error and print_info functions
wrap echo with these colors so every message looks different and easy to read.

---

### 2. Logging (log function)

```bash
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}
```

Every single thing the script does gets written to setup_log.txt with a timestamp.
This is useful because if something goes wrong you can open the log and see exactly
what happened and when. The >> means append to the file without overwriting it.

---

### 3. Progress Bar

```bash
progress_bar() {
    local duration=$1
    local steps=20
    ...
}
```

This function draws a loading bar made of block characters in the terminal.
It divides the total duration by 20 steps and sleeps between each one.
This is purely cosmetic but it makes the script feel professional and gives
the user visual feedback that something is happening.

---

### 4. The Banner

```bash
print_banner() {
    echo "╔══════════════════════════════════════╗"
    echo "║   ATTENDANCE TRACKER BOOTSTRAPPER    ║"
    echo "╚══════════════════════════════════════╝"
}
```

A decorative header printed at the start. Makes the script feel like a real tool.

---

### 5. The SIGINT Trap (Most Important Part!)

```bash
trap cleanup_on_interrupt SIGINT
```

This is the signal trap. SIGINT is the signal sent when you press Ctrl+C.
Normally Ctrl+C just stops the script immediately and leaves a mess.

With trap, we intercept that signal and run our own cleanup_on_interrupt
function instead of just stopping.

The cleanup function does three things:
1. Creates an archive (tar.gz) of whatever was built so far
2. Deletes the incomplete project folder
3. Prints a friendly message and exits cleanly

WHY: In professional environments you never want to leave half-created files
behind. If a deployment fails you want to clean up automatically.

---

### 6. Health Check

```bash
if python3 --version &>/dev/null; then
    print_success "Python3 found"
else
    print_warning "Python3 NOT installed"
fi
```

Before building anything the script checks if the tools needed to run the
project are actually installed. The &>/dev/null part hides the output of
the command so we only see our own message.

This is called a pre-flight check in professional software deployment.

---

### 7. Duplicate Check

```bash
if [ -d "$PROJECT_DIR" ]; then
    read -rp "Project exists. Overwrite/Rename/Cancel? " choice
```

The -d flag checks if a directory already exists.
If it does the user gets three options:
- Overwrite: delete the old one and start fresh
- Rename: pick a different name
- Cancel: stop the script

WHY: Without this check the script would just overwrite existing work silently.

---

### 8. Build Structure

```bash
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
touch "$PROJECT_DIR/attendance_checker.py"
```

mkdir -p creates the folder AND any parent folders needed in one command.
touch creates empty files.
This builds the entire skeleton of the project in seconds.

---

### 9. Populate Files

```bash
cp "$SCRIPT_DIR/attendance_checker.py" "$PROJECT_DIR/attendance_checker.py"
```

After the structure is built, the actual source files are copied into it.
If a file is not found the script creates a placeholder instead of crashing.

---

### 10. Configure Thresholds with sed

```bash
sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" config.json
```

This is the sed (stream editor) command.

Breaking it down:
- sed -i means edit the file in place (directly, no copy)
- s/ means substitute (find and replace)
- \"warning\": [0-9]* means find the word "warning" followed by any number
- \"warning\": $new_warning means replace it with the new value

WHY: This allows us to change values inside a JSON file from the terminal
without opening it in a text editor. This is how professional deployment
scripts configure applications.

---

### 11. Configure Run Mode (Extra Feature)

```bash
sed -i "s/\"run_mode\": \"[^\"]*\"/\"run_mode\": \"$run_mode\"/" config.json
```

Similar to the threshold configuration, this uses sed to update the run_mode
field in config.json. The user can choose between:
- live: actually sends alerts and writes to log
- dry_run: simulates everything without writing anything

WHY: dry_run mode is a professional concept. It lets you test the system
without causing any real effects. Very useful for testing.

---

### 12. Auto Git Init (Extra Feature)

```bash
git init
echo "reports/*.archive" > .gitignore
git add .
git commit -m "Initial project setup"
```

After building the project, the script can optionally initialize a git
repository inside it. It also creates a .gitignore file to exclude
log archives and Python cache folders from being tracked.

WHY: In real software teams every project lives in version control from
day one. Automating this saves time and ensures consistency.

---

### 13. Summary Report

```bash
find "$PROJECT_DIR" -type f | sort | while read -r file; do
    echo "  ✔ $file"
done
```

At the end the script lists every single file that was created using the
find command. find searches recursively through the folder and -type f
means only show files not directories.

WHY: This acts like a receipt. The user can immediately verify that everything
was created correctly without having to manually check.

---

### 14. main() Function

```bash
main() {
    print_banner
    # ask for name
    # duplicate check
    # health check
    # build structure
    # populate files
    # configure thresholds
    # configure run mode
    # git init
    # print summary
}
main
```

All the functions are defined above and then called in order inside main().
The last line main calls it. This is a clean programming pattern that makes
the script easy to read and modify.

---

## How To Run The Script

```bash
chmod u+x setup_project.sh
bash setup_project.sh
```

Then follow the prompts.

---

## How To Trigger The Archive Feature

While the script is running press Ctrl+C at any point.
The trap will catch the signal, archive whatever was created so far
into a .tar.gz file, clean up the incomplete folder and exit gracefully.

---

## Extra Features Added Beyond Requirements

| Feature | Why Added |
|---|---|
| Colored output | Professional appearance, easier to read |
| Progress bar | Visual feedback for the user |
| Timestamp logging | Debugging and audit trail |
| Duplicate check | Prevents accidental overwriting |
| Run mode config | Professional dry_run testing support |
| Auto git init | Real-world deployment best practice |
| Summary report | Verification receipt at end of setup |
| Input validation | Prevents invalid threshold values |
