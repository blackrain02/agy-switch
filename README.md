# agy-switch

> Fast multi-account switcher and real-time quota monitor for **Google Antigravity (AGY)** on Linux, macOS, and WSL.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey.svg)]()

`agy-switch` lets you seamlessly store, manage, and toggle between multiple Google Antigravity accounts with zero friction. It tracks remaining **5-hour** and **Weekly** quotas in real time, auto-refreshes OAuth credentials in the background, and allows porting sessions between workstations via selective export/import bundles.

---

## ✨ Features

- ⚡ **Instant Account Switching**: Switch profiles instantly by number (`agy-switch 1`), by email, or via the interactive menu.
- 📊 **Real-Time Quota Telemetry**: View remaining Gemini and Claude/GPT quota percentages alongside reset countdown timers.
- 🚀 **High Performance (<50ms)**: Built-in 5-minute quota cache and token expiry checks eliminate unnecessary network roundtrips.
- ⏳ **Terminal Skeleton Loading**: Fast progressive UI rendering using ANSI cursor rewriting while parallel quota threads resolve.
- 📦 **Selective Export & Import**: Transfer all or selected accounts to a new machine or VPS with automatic token refresh and path adaptation.
- 🛡️ **Self-Healing Guardian Wrapper**: Re-authenticates expiring tokens on the fly and shields active sessions against accidental logout wipes.
- 🪶 **Zero External Dependencies**: 100% standard Python 3 (`json`, `urllib`, `subprocess`, `threading`, `concurrent.futures`).

---

## 🖥️ Preview

### Interactive Menu
```text
Saved accounts:
  [1] user.work@gmail.com                     [Gemini: 5h: 100% | Wk: 98%]
  [2] personal@gmail.com                      [Gemini: 5h: 100% | Wk: 100%]
  [3] standby.account@gmail.com  * (active)   [Gemini: 5h: 82% | Wk: 80%]

Commands:
  [1-N] Select account number to switch
  [s]   Save current account as a new entry
  [e]   Export accounts to a backup file
  [i]   Import accounts from a backup file
  [r]   Refresh quota data
  [l]   Logout from current account
  [q]   Quit

Enter choice: 
```

### Comparative Quota Table (`agy-switch -l`)
```text
┌───┬─────────────────────────────┬──────────────┬──────────────┬─────────────┬─────────────┬──────────┐
│ # │ Account                     │ Gemini (5h)  │ Gemini (Wk)  │ Claude (5h) │ Claude (Wk) │ Status   │
├───┼─────────────────────────────┼──────────────┼──────────────┼─────────────┼─────────────┼──────────┤
│ 1 │ user.work@gmail.com         │ 100%         │ 98% (2d 21h) │ 100%        │ 100%        │          │
│ 2 │ personal@gmail.com          │ 100%         │ 100%         │ 100%        │ 100%        │          │
│ 3 │ standby.account@gmail.com   │ 82% (3h 55m) │ 80% (3d 21h) │ 100%        │ 100%        │ * active │
└───┴─────────────────────────────┴──────────────┴──────────────┴─────────────┴─────────────┴──────────┘
```

---

## 🚀 Quick Install

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/blackrain02/agy-switch/main/install.sh | bash
```

### Manual Installation

Clone the repository and link the script into your `$PATH`:

```bash
git clone https://github.com/blackrain02/agy-switch.git
cd agy-switch
mkdir -p ~/.local/bin
cp agy-switch ~/.local/bin/
chmod +x ~/.local/bin/agy-switch

# Ensure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

Verify installation:
```bash
agy-switch --version 2>/dev/null || agy-switch --help
```

---

## 📖 Usage Guide

### 1. Saving Your Accounts
Log in to your first account using standard `agy`, then save it:

```bash
agy                   # Complete browser OAuth login
agy-switch -s         # Saves active account (auto-detects email or custom label)
```

To add another account:
```bash
agy-switch --logout   # Clears active session
agy                   # Complete browser login for the second account
agy-switch -s         # Save second profile
```

### 2. Switching Between Accounts
Launch the interactive switcher:
```bash
agy-switch
```

Or switch directly from your terminal:
```bash
agy-switch 1                  # Switch to account #1
agy-switch 2                  # Switch to account #2
agy-switch user.work@gmail.com # Switch by email or matching label
```

### 3. Monitoring Quota Limits
View the complete breakdown for both Gemini and 3P models:
```bash
agy-switch -l
```

Force-refresh quotas bypassing the 5-minute cache:
```bash
agy-switch -r        # Interactive menu with forced refresh
agy-switch -l -r     # Comparative table with forced refresh
```

### 4. Exporting & Importing Accounts (Multi-Machine Sync)
Transfer accounts to another laptop or remote server without logging in via browser again:

```bash
# Export all accounts
agy-switch -e backup.json

# Export selected accounts only
agy-switch -e backup.json 1 2
agy-switch -e backup.json user.work@gmail.com

# Import on target machine
agy-switch -i backup.json
```
The importer automatically:
1. Rewrites file paths to match the target machine's `$HOME`.
2. Merges accounts into the local manifest.
3. Automatically refreshes expired OAuth access tokens.
4. Installs the self-healing guardian wrapper.

---

## ⚙️ Command-Line Interface

```text
usage: agy-switch [-h] [-s [SAVE]] [-w ACCOUNT] [-d ACCOUNT] [-l] [-r]
                  [-e [ARG ...]] [-i FILE] [--logout] [--install-guard]
                  [account]

positional arguments:
  account               Account number or name to switch to

options:
  -h, --help            Show this help message and exit
  -s, --save [NAME]     Save active account (optional custom name)
  -w, --switch ACCOUNT  Switch to account by name or index
  -d, --delete ACCOUNT  Delete a saved account by number or name
  -l, --list            Display detailed quota table
  -r, --refresh         Force refresh quota cache
  -e, --export [ARG ...] Export accounts: --export [FILE] [ACCOUNTS...]
  -i, --import FILE     Import accounts from backup file
  --logout              Clear active session to login to a new account
  --install-guard       Reinstall transparent auto-login wrapper
```

---

## 🔒 Security & Privacy

- All OAuth tokens and refresh tokens are stored locally on your machine at `~/.gemini/accounts/` with strict `0600` permissions.
- No tokens, logs, or analytics are ever transmitted to third-party servers.
- Requests are sent exclusively to Google's official endpoints (`oauth2.googleapis.com`) for standard OAuth token renewal.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
