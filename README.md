# SearxNG Local for macOS

An installer for running your own **private SearxNG** instance on macOS — isolated in a virtual environment under your user folder, no root permissions or global changes.

---

## Prerequisites

- macOS 13 or later, including macOS 26+ (Apple Silicon or Intel)
- Homebrew installed (`brew --version` should work)

If you don't have Homebrew, run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## Installation

```bash
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

## Auto-Start on Login

To have SearxNG start automatically when you log in:
```bash
bash setup-autostart.sh
```

To disable auto-start later:
```bash
launchctl unload ~/Library/LaunchAgents/com.searxng.local.plist
```

---

## Uninstall

To completely remove everything (including auto-start):
```bash
bash sx-uninstall-mac.sh
```

---

## Troubleshooting

### "Sorry! No results were found" with errors next to engine names

Open the results page and look under **Messages from the search engines**. The
error text tells you which of these it is.

**`too many requests` / engine works then disappears.**
SearXNG suspends an engine that rate-limits it (Brave for 180s, Startpage for
3600s), and a retry inside that window re-suspends it — so a brief hiccup can
look like a permanently dead engine. Restart to clear the timers:

```bash
~/Documents/searxng-mac/stop-searx-mac.sh
~/Documents/searxng-mac/start-searx-mac.sh
```

If an engine only drops out after several searches in a row, that is normal
rate-limiting, not a fault.

**`CAPTCHA` — usually a VPN.**
Startpage, Qwant and Brave block or challenge shared VPN exit IPs. Startpage's
block page names the provider directly. If you search through a VPN, expect
these engines to be unreliable and lean on ones that tolerate it — Bing,
Mojeek, Yahoo and Wikipedia are dependable. Enable them in
`~/Documents/searxng-mac/settings.yml`:

```yaml
engines:
  - name: bing
    engine: bing
    disabled: false
  - name: mojeek
    engine: mojeek
    disabled: false
  - name: yahoo
    engine: yahoo
    disabled: false
```

Then restart SearxNG.

**`HTTP error` from DuckDuckGo.**
DuckDuckGo currently returns `406 Not Acceptable` to SearXNG's HTTP client
while accepting an ordinary browser from the same machine — it is fingerprinting
the TLS handshake. Nothing to fix locally; it comes and goes as SearXNG works
around it upstream, so keep SearXNG updated. The search-box autocomplete uses a
different DuckDuckGo endpoint and is unaffected.

**`HTTP connection error` from a single engine.**
Check that its hostname actually resolves. Ad-blocking DNS (Pi-hole,
pfBlockerNG, AdGuard Home) sometimes sinkholes engine domains:

```bash
dscacheutil -q host -a name cse.google.com
```

A result of `0.0.0.0`, or no address at all, means your DNS is blocking it.
Allow the domain in your blocker, or disable that engine.

### Disabling an engine

Add it to the `engines:` list in `~/Documents/searxng-mac/settings.yml`:

```yaml
engines:
  - name: startpage
    engine: startpage
    disabled: true
```

Note that the autocomplete backend set under `search: autocomplete:` needs its
engine left enabled — disabling the DuckDuckGo engine while
`autocomplete: 'duckduckgo'` is set will break the search box's suggestions.
Point `autocomplete:` at an engine you have kept enabled, such as `'google'`.

### Checking the logs

The installer silences SearXNG's own logging. In auto-start mode, engine
failures land in the LaunchAgent log:

```bash
tail -f ~/Library/Logs/searxng.error.log
```

They appear as `WARNING:searx.engines.<name>: ErrorContext(...)` with the
underlying exception at the end of the line.

---

## Notes

- Everything runs in your home directory — no sudo needed.
- SearxNG is installed to `~/Documents/searxng-mac`.
- Auto-start logs are written to `~/Library/Logs/searxng.log` and `~/Library/Logs/searxng.error.log`.
- You can clone this repo anywhere — only the deploy script matters.
