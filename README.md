# SearxNG Local for macOS

SORRY.  THIS WAS WORKING PERFECTLY FOR A MONTH OR SO, ok no more caps, but some changes were made on the SearxNG side and the script no longer works.
Anyone is welcome to take what's here and try to get it working.  
It was really useful for setting SearxNG up on friends' computers and I do plan to try to make a new working version at some point, but not sure when I'll have time. 
Anyway, for what it's worth......

The good news is that the instructions from SearxNG themselves are much clearer than what I remember before.  I installed it with no issues by following the instrux on their website at https://docs.searxng.org/admin/installation-searxng.html

-------

An installer for running your own **private SearxNG** instance on macOS — isolated in a virtual environment under your user folder, no root permissions or global changes.  Started and stopped by a terminal command.

---

## 🧩 Prerequisites

- macOS 13 or later (Apple Silicon or Intel)
- Homebrew installed (`brew --version` should work)

If you don’t have Homebrew, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 🧰 Installation

```bash
cd ~/Documents
git clone https://github.com/invisi101/searx-mac-local.git
cd searx-mac-local
bash sx-deploy-mac.sh
```

This will:
- Install Python 3.12 via Homebrew if missing
- Clone the latest SearxNG source code
- Build it inside a self-contained Python virtual environment
- Create easy `start-searxng` and `stop-searxng` commands in `~/.local/bin`

---

## 🚀 Usage

To start SearxNG:
```bash
start-searxng
```

Visit [http://127.0.0.1:8888](http://127.0.0.1:8888)

To stop SearxNG:
```bash
stop-searxng
```

---

## 🧹 Uninstall

To completely remove everything:
```bash
rm -rf ~/Documents/searxng-mac ~/.local/bin/start-searxng ~/.local/bin/stop-searxng
```
Only the cloned git repo folder will remain, in case you decide you want to reinstall.  Or just delete it manually.
---

## ⚙️ Notes

- Everything runs in your home directory — no sudo needed.
- Python 3.12 is sandboxed under `/opt/homebrew/Cellar/python@3.12/`.
- The app does **not** auto-start; you control when it runs.

---

## ⚠️ PLEASE NOTE — Command Not Found Fix

If you see an error like, "zsh: command not found: start-searxng" or "bash: start-searxng: command not found"
then the scripts were installed correctly, but your shell cannot find them because the directory `~/.local/bin` is not in your PATH.  Here’s how to fix it depending on your setup

---
### 🧩 For **zsh** (default shell on macOS 10.15+)
1. Add the local bin directory to your PATH:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
   ```
2. Apply the change:
   ```bash
   source ~/.zprofile
   ```
3. Verify:
   ```bash
   which start-searxng
   ```
   You should see:
   ```
   /Users/yourname/.local/bin/start-searxng
   ```

> 💡 You can also add the same line to `~/.zshrc` if you want it available in non-login shells (e.g., iTerm or VS Code terminals).

---

### 🧩 For **bash**
1. Add this line:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
   ```
2. Reload your profile:
   ```bash
   source ~/.bash_profile
   ```
3. Test the command again:
   ```bash
   start-searxng
   ```
---

### 🧩 Verify installation
Check that both helper scripts exist:
```bash
ls ~/.local/bin/start-searxng ~/.local/bin/stop-searxng
```
If they’re missing, re-run the installer:
```bash
bash sx-deploy-mac.sh
```
------
