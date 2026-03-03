# Bootstrap Scripts Improvement Plan

## Overview
Fix critical issues and improve the bootstrap scripts for macOS, Linux, and Raspberry Pi.

---

## Phase 1: Critical Fixes (High Priority)

### 1.1 Error Handling & Safety
- [ ] Add `set -euo pipefail` to both scripts
- [ ] Add error checking for critical commands (curl, apt, brew, etc.)
- [ ] Quote all variables properly (`"$var"` instead of `$var`)

### 1.2 SSH & Security
- [ ] Fix missing `chmod` for `~/.ssh/authorized_keys` in setup_rasp.sh (line 74)
- [ ] Fix `~/.ssh` directory creation and permissions
- [ ] Fix `safe.directory` handling - use repo-specific instead of global wildcard

### 1.3 Deprecated URLs
- [ ] Update oh-my-zsh repo URL from `robbyrussell/oh-my-zsh` to `ohmyzsh/ohmyzsh` (setup_rasp.sh line 34)
- [ ] Fix oh-my-zsh installer syntax (setup.sh line 18)

---

## Phase 2: Reliability Improvements

### 2.1 Docker Detection
- [ ] Improve Docker detection in setup.sh - check `/proc/1/cgroup` in addition to `/.dockerenv`

### 2.2 Download Reliability
- [ ] Add error handling for curl downloads (tmux configs in setup.sh lines 52-53)
- [ ] Add file existence checks before proceeding

### 2.3 Variable & Logic Fixes
- [ ] Fix `$ZSH_CUSTOM` used before being set (setup_rasp.sh line 35)
- [ ] Remove redundant `read to_continue` (setup.sh lines 102, 123)
- [ ] Fix `hash $val` to `hash -- "$val"` (setup.sh line 178)

---

## Phase 3: Idempotency & Robustness

### 3.1 Make Scripts Re-run Safe
- [ ] Check if already configured before running setup functions
- [ ] Add backup before overwriting config files
- [ ] Add "force" flag to override existing checks

### 3.2 Input Validation
- [ ] Validate user inputs (email format, file paths, etc.)
- [ ] Add default values where appropriate

### 3.3 Logging
- [ ] Add logging to file with timestamps
- [ ] Add verbose mode flag

---

## Phase 4: General Improvements

### 4.1 Raspberry Pi Specific
- [ ] Make hostname check less fragile (setup_rasp.sh lines 89-99)
- [ ] Fix sed command to be more specific (avoid corrupting other files)
- [ ] Show apt output instead of suppressing it completely

### 4.2 Code Quality
- [ ] Extract common functions to reduce duplication
- [ ] Add usage/help flag (`--help`, `--dry-run`)
- [ ] Add shebang with `-u` flag

### 4.3 Dockerfile
- [ ] Add `apt-get clean` to reduce image size
- [ ] Combine RUN commands to reduce layers
- [ ] Add error handling

---

## Phase 5: Optional Enhancements

- [ ] Add interactive vs non-interactive mode
- [ ] Add support for more Linux distros (Fedora, Arch)
- [ ] Add config file for default answers
- [ ] Add sanity checks (disk space, network, etc.)

---

## Implementation Order

1. **setup.sh** - Critical fixes first (error handling, quoting, safe.directory)
2. **setup_rasp.sh** - SSH permissions, deprecated URLs, apt output
3. **Dockerfile** - Cleanup and efficiency
4. **Testing** - Verify scripts work on fresh installs
