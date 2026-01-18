# SearxNG Local for macOS

An installer for running your own **private SearxNG** instance on macOS — isolated in a virtual environment under your user folder, no root permissions or global changes.

---

## Prerequisites

- macOS 13 or later (Apple Silicon or Intel)
- Homebrew installed (`brew --version` should work)

If you don't have Homebrew, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## Installation

```bash
cd ~/Documents
git clone https://github.com/invisi101/searx-mac-local.git
cd searx-mac-local
bash sx-deploy-mac.sh
```

This will:
- Install Python 3.11 and build dependencies via Homebrew
- Clone the latest SearxNG source code
- Build it inside a self-contained Python virtual environment
- Configure settings with a random secret key

---

## Usage

To start SearxNG:
```bash
~/Documents/searxng-mac/start-searx-mac.sh
```

Visit [http://127.0.0.1:8888](http://127.0.0.1:8888)

To stop SearxNG:
```bash
~/Documents/searxng-mac/stop-searx-mac.sh
```

---

## Uninstall

To completely remove everything:
```bash
bash sx-uninstall-mac.sh
```

---

## Notes

- Everything runs in your home directory — no sudo needed.
- SearxNG is installed to `~/Documents/searxng-mac`.
- The app does **not** auto-start; you control when it runs.
