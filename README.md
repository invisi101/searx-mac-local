# SearxNG Local for macOS

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
