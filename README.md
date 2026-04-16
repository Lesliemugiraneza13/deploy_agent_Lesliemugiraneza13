# this is to anyone that might use this in the future
# deploy_agent_Lesliemugiraneza13

## Automated Project Bootstrapper for Student Attendance Tracker

---

## What This Does

This script automates the creation of a fully structured workspace for the
Student Attendance Tracker project. Instead of manually creating folders and
files, you run one script and the entire environment is ready in seconds.

---

## How To Run

**Step 1 — Clone the repository**
```bash
git clone https://github.com/Lesliemugiraneza13/deploy_agent_Lesliemugiraneza13.git
cd deploy_agent_Lesliemugiraneza13
```

**Step 2 — Make the script executable**
```bash
chmod u+x setup_project.sh
```

**Step 3 — Run the script**
```bash
bash setup_project.sh
```

**Step 4 — Follow the prompts**
- Enter a project name (e.g. v1, dev, prod)
- Choose whether to update attendance thresholds
- Choose run mode (live or dry_run)
- Choose whether to initialize git

---

## How To Trigger The Archive Feature

While the script is running, press **Ctrl+C** at any point.

The script will:
1. Catch the interruption signal
2. Bundle everything created so far into a `.tar.gz` archive
3. Delete the incomplete folder
4. Exit cleanly

The archive will be named: `attendance_tracker_{input}_archive.tar.gz`

---

## Files Included

| File | Description |
|---|---|
| `setup_project.sh` | The main bootstrap script |
| `EXPLANATION.md` | Full breakdown of how the script works |
| `attendance_checker.py` | Python attendance logic |
| `assets.csv` | Student attendance data |
| `config.json` | Configuration with thresholds |
| `reports.log` | Sample attendance report output |

---

## Extra Features

- Colored terminal output for easy reading
- Progress bar during setup
- Timestamp logging to setup_log.txt
- Duplicate project detection with options
- Run mode configuration (live / dry_run)
- Optional automatic git repository initialization
- Full summary report at the end

---

## Requirements

- Ubuntu 20.04 or any Linux system
- bash
- python3 (optional, needed to run the attendance checker)
- git (optional, needed for auto git init feature)
- tar (needed for archive feature)
