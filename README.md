# SearxNG Local for macOS

A lightweight, self-contained local search engine running on your Mac.  
Installs fully inside `~/Documents/searxng-mac`, with no background services or system modifications.

## Installation

```bash
cd ~/Documents
git clone https://github.com/invisi101/searx-mac-local.git
cd searx-mac-local
bash sx-deploy-mac.sh
```

## Usage

Start:
```bash
bash ~/Documents/searxng-mac/start-searx-mac.sh
```

Stop:
```bash
bash ~/Documents/searxng-mac/stop-searx-mac.sh
```

Then open:
```
http://127.0.0.1:8888
```

## Uninstall

```bash
bash ~/Documents/searx-mac-local/sx-uninstall-mac.sh
```

## Notes

- Runs entirely locally — no root or daemon needed.  
- You can optionally make an Automator app later for GUI “Start/Stop” buttons.
