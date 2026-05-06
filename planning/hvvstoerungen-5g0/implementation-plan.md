# Implementation Plan: Extract HVV Info (`hvvstoerungen-5g0`)

## Context

**Problem statement:** The HVV disruption page at
`https://www.nahverkehrhamburg.de/hvv-stoerungen-heute/` contains relevant
disruption tiles but also a newsletter popup, navigation, sidebars, and ads.
The user needs a clean view of only the yellow and red disruption tiles inside
a Home Assistant dashboard — without a separate HA add-on.

**Desired outcome:** A Lovelace custom card in the HA dashboard that shows only
the yellow and red `hvv-line-card` tiles from the HVV disruption page, updated
every 5 minutes automatically.

**CORS constraint:** `nahverkehrhamburg.de` returns no `Access-Control-Allow-Origin`
header. A Lovelace card cannot directly fetch the external page from the browser.
The solution uses a server-side scraper that writes pre-filtered HTML to HA's
`www/` directory (served as `/local/`), which the card fetches same-origin.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  Home Assistant Host                                            │
│                                                                 │
│  ┌────────────────────┐   every 5 min    ┌──────────────────┐  │
│  │  HA Automation     │ ─────────────── ▶│  hvv_scraper.py  │  │
│  │  shell_command     │                  │  (Python script) │  │
│  └────────────────────┘                  └────────┬─────────┘  │
│                                                   │             │
│                                     writes        ▼             │
│                                          /config/www/           │
│                                          hvv_tiles.html         │
│                                                   │             │
│  ┌────────────────────────────────────┐  /local/  │             │
│  │  HA Dashboard (browser)            │ ◀─────────┘             │
│  │  ┌──────────────────────────────┐  │                         │
│  │  │  hvv-stoerungen-card (JS)    │  │                         │
│  │  │  fetch('/local/hvv_tiles…')  │  │                         │
│  │  │  [🔴 A2]  [🟡 S1]  ...      │  │                         │
│  │  └──────────────────────────────┘  │                         │
│  └────────────────────────────────────┘                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Scope

### In scope
- `hvv_scraper.py`: Python script that fetches the HVV page, extracts only
  `hvv-line-card status-red` and `hvv-line-card status-yellow` tiles,
  preserves the original CSS `<link>` tags, removes the mailster popup,
  and writes a self-contained HTML fragment to `/config/www/hvv_tiles.html`
- `hvv-stoerungen-card.js`: Lovelace custom element (vanilla JS, no build step)
  that fetches `/local/hvv_tiles.html` and renders it inside the card
- HA configuration snippets (`configuration.yaml` additions) for `shell_command`
  and an automation that triggers the scraper every 5 minutes
- Unit tests for the Python scraper

### Out of scope
- HA Add-on / Docker container
- Authentication or API keys
- Filtering by specific line (S1, U2, etc.)
- Historical disruption storage
- Push notifications

---

## Architecture Constraints

| Constraint | Specification | Source |
|---|---|---|
| No CORS on target site | `nahverkehrhamburg.de` returns no `Access-Control-Allow-Origin`; browser fetch blocked | Verified via `curl -I` |
| Static HTML delivery | Scraper writes to `/config/www/`; card reads `/local/` (same HA origin) | HA `www` folder convention |
| No add-on | Solution must run as HA configuration (shell_command), not a Docker add-on | User requirement |
| No build step for JS | Card must work as a plain `.js` file dropped in `/config/www/`; no webpack | HA custom card convention |
| Page is server-rendered | Full tile HTML available in initial HTTP response; no JS rendering needed | Verified: 3 red + 8 yellow tiles in raw HTML |

---

## Key Design Decisions

### Decision 1: Server-side scrape → `/local/` file, not client-side fetch

**Decision:** The Python scraper runs on the HA host and writes pre-filtered HTML
to `/config/www/hvv_tiles.html`. The Lovelace card fetches this local file.

**Rationale:** CORS blocks any direct browser fetch to `nahverkehrhamburg.de`.
All alternatives (CORS proxy add-on, HA REST sensor) are either add-ons or
unsuitable for large HTML payloads (HA state attributes are capped at ~16 KB;
the full page is 434 KB). Writing to `/config/www/` is a standard HA pattern for
serving local files and requires no add-on.

**Tradeoff:** Requires the scraper to be invoked periodically on the HA host.
The `shell_command` + automation approach works on HA OS, HA Supervised, and
Docker Core installs where a Python binary is available. Bare-metal HA Core is
also supported since Python is always present.

---

### Decision 2: Vanilla JS Lovelace card, no framework

**Decision:** The card is a plain `HTMLElement` custom element with no LitElement,
React, or build toolchain.

**Rationale:** A build step (webpack/rollup) would require Node.js on the HA host
and makes the card much harder to install. The card's rendering logic is trivial
(fetch a URL, inject `innerHTML`). Vanilla custom elements are fully supported in
all modern browsers.

**Tradeoff:** No reactive bindings; the card re-fetches and re-renders on each
`hass` update. Acceptable for a 5-minute refresh cycle.

---

### Decision 3: Preserve original CSS `<link>` tags

**Decision:** Copy all `<link rel="stylesheet">` tags from the HVV page into the
output HTML fragment. Do not inline or rewrite CSS.

**Rationale:** The tile grid and colour styling are complex (~500 lines of CSS).
Copying the `<link>` tags is a single line of Beautiful Soup code. The stylesheets
are public assets that load in the browser without authentication.

**Tradeoff:** Tiles render without styling if the host has no internet access.
Acceptable for a personal home dashboard.

---

### Decision 4: Filter by `.hvv-line-card` class + `status-red/yellow` modifier

**Decision:** Select tiles via `soup.find_all("div", class_=lambda c: c and
"hvv-line-card" in c and ("status-red" in c or "status-yellow" in c))`.

**Rationale:** `status-red` / `status-yellow` are explicit semantic classes on
`data-sort-ampel` elements; more stable than colour values. The double-class
check (both `hvv-line-card` and `status-*`) avoids false-positive matches on
KPI value spans that also carry `status-red/yellow`.

---

### Decision 5: Scraper triggered via HA `shell_command` + automation

**Decision:** Register the scraper as a `shell_command` in `configuration.yaml`
and trigger it from a time-pattern automation every 5 minutes.

**Rationale:** This is the standard HA pattern for running arbitrary scripts.
No extra dependencies. Runs on all HA install methods. The interval can be
adjusted in the automation without touching the scraper code.

---

## Project Structure

```
hvvstoerungen/
├── hvv_scraper.py             NEW  — Python fetch/filter script
├── hvv-stoerungen-card.js     NEW  — Lovelace custom element
├── requirements.txt           NEW  — requests, beautifulsoup4, lxml
├── ha_config/
│   └── configuration_snippet.yaml  NEW  — shell_command + automation config
└── tests/
    ├── test_scraper.py        NEW  — unit tests
    └── fixtures/
        └── page_sample.html   NEW  — minimal fixture with 2 red, 1 yellow, 1 green + popup
```

**Deployment mapping:**

| File | Copy to HA host |
|---|---|
| `hvv_scraper.py` | `/config/hvv_scraper.py` |
| `hvv-stoerungen-card.js` | `/config/www/hvv-stoerungen-card.js` |
| `ha_config/configuration_snippet.yaml` | Merge into `/config/configuration.yaml` |

---

## Module Specification: `hvv_scraper.py`

**Purpose:** Fetch the HVV disruption page, extract red/yellow tiles and their
CSS, and write a clean HTML fragment to a configurable output path.

**CLI interface:**

```
python3 hvv_scraper.py [--output PATH]

  --output PATH   Destination file (default: /config/www/hvv_tiles.html)
```

**Key functions (pseudo-code sketch):**

```python
URL = "https://www.nahverkehrhamburg.de/hvv-stoerungen-heute/"
HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; hvvstoerungen/1.0)"}

def fetch_page(url: str, timeout: int = 15) -> str:
    resp = requests.get(url, headers=HEADERS, timeout=timeout)
    resp.raise_for_status()
    return resp.text

def extract_stylesheets(soup: BeautifulSoup) -> list[Tag]:
    return soup.find_all("link", rel="stylesheet")

def extract_tiles(soup: BeautifulSoup) -> list[Tag]:
    return soup.find_all(
        "div",
        class_=lambda c: c and "hvv-line-card" in c
            and ("status-red" in c or "status-yellow" in c),
    )

def extract_last_update(soup: BeautifulSoup) -> str | None:
    el = soup.find(class_="last-update-notice")
    return el.get_text(strip=True) if el else None

def build_html(
    stylesheets: list[Tag],
    tiles: list[Tag],
    last_update: str | None,
    fetched_at: str,          # ISO timestamp for staleness display
) -> str:
    """Return a standalone HTML document containing only the tiles."""
    css_links = "\n".join(str(tag) for tag in stylesheets)
    tile_html = "\n".join(str(t) for t in tiles)
    update_line = f"<p class='update-notice'>{last_update} · abgerufen {fetched_at}</p>"
    return f"""<!DOCTYPE html>
<html lang="de">
<head><meta charset="UTF-8">{css_links}
<style>
  body {{ margin: 0; background: transparent; }}
  .tile-grid {{ display: flex; flex-wrap: wrap; gap: 8px; padding: 8px; }}
  .update-notice {{ font-size: 0.75rem; color: #888; padding: 4px 8px; }}
</style>
</head>
<body>
  {update_line}
  <div class="tile-grid">{tile_html}</div>
</body></html>"""

def write_output(html: str, path: str) -> None:
    Path(path).write_text(html, encoding="utf-8")

def main() -> None:
    args = parse_args()
    html = fetch_page(URL)
    soup = BeautifulSoup(html, "lxml")
    output = build_html(
        extract_stylesheets(soup),
        extract_tiles(soup),
        extract_last_update(soup),
        datetime.now().strftime("%H:%M Uhr"),
    )
    write_output(output, args.output)
    print(f"Written {len(extract_tiles(soup))} tiles to {args.output}")
```

**Exit codes:** 0 = success, 1 = HTTP error or write failure (logged to stderr).

---

## Module Specification: `hvv-stoerungen-card.js`

**Purpose:** Lovelace custom element that periodically fetches
`/local/hvv_tiles.html` and renders it inside the HA dashboard card.

**Card config (dashboard YAML):**
```yaml
type: custom:hvv-stoerungen-card
refresh_interval: 300   # seconds (default 300 = 5 min)
```

**Implementation sketch:**

```javascript
class HvvStoerungsCard extends HTMLElement {
  setConfig(config) {
    this._interval = (config.refresh_interval ?? 300) * 1000;
  }

  set hass(_) {
    // called on every HA state update; only start polling once
    if (!this._started) {
      this._started = true;
      this._render();
      this._timer = setInterval(() => this._render(), this._interval);
    }
  }

  async _render() {
    try {
      const resp = await fetch(`/local/hvv_tiles.html?_=${Date.now()}`);
      if (!resp.ok) throw new Error(resp.statusText);
      const html = await resp.text();
      this.innerHTML = html;
    } catch (e) {
      this.innerHTML = `<p style="color:red">HVV-Daten nicht verfügbar: ${e.message}</p>`;
    }
  }

  disconnectedCallback() {
    clearInterval(this._timer);
  }

  getCardSize() { return 3; }
}

customElements.define("hvv-stoerungen-card", HvvStoerungsCard);
```

**Cache busting:** The `?_=<timestamp>` query string prevents browser caching of
the local file so the card always shows the latest scraper output.

---

## Module Specification: `ha_config/configuration_snippet.yaml`

```yaml
shell_command:
  hvv_scraper: "python3 /config/hvv_scraper.py --output /config/www/hvv_tiles.html"

automation:
  - alias: "HVV Störungen aktualisieren"
    trigger:
      - platform: time_pattern
        minutes: "/5"
    action:
      - service: shell_command.hvv_scraper
```

**Lovelace resource registration** (UI: Settings → Dashboards → Resources, or
`configuration.yaml`):

```yaml
lovelace:
  resources:
    - url: /local/hvv-stoerungen-card.js
      type: module
```

---

## Test Strategy

**Coverage target:** >90% for `hvv_scraper.py`.

**Test fixture:** `tests/fixtures/page_sample.html` — minimal HTML with:
- 2 red `hvv-line-card` tiles
- 1 yellow `hvv-line-card` tile
- 1 green `hvv-line-card` tile (must be excluded)
- 1 `mailster-block-form-type-popup` div (must be excluded)
- 2 `<link rel="stylesheet">` tags
- A `.last-update-notice` element

**Test cases:**

```python
def test_extract_tiles_returns_only_red_and_yellow(sample_soup):
    tiles = extract_tiles(sample_soup)
    assert len(tiles) == 3  # 2 red + 1 yellow

def test_extract_tiles_excludes_green(sample_soup):
    tiles = extract_tiles(sample_soup)
    for t in tiles:
        assert "status-green" not in t.get("class", [])

def test_extract_tiles_excludes_kpi_spans(sample_soup):
    # KPI value spans also carry status-red/yellow but are not hvv-line-card
    tiles = extract_tiles(sample_soup)
    for t in tiles:
        assert "hvv-line-card" in t.get("class", [])

def test_extract_stylesheets_returns_link_tags(sample_soup):
    sheets = extract_stylesheets(sample_soup)
    assert len(sheets) == 2
    for s in sheets:
        assert s.name == "link"

def test_extract_last_update_found(sample_soup):
    text = extract_last_update(sample_soup)
    assert text is not None and "Stand:" in text

def test_extract_last_update_missing(empty_soup):
    assert extract_last_update(empty_soup) is None

def test_build_html_excludes_mailster(sample_soup):
    html = build_html(
        extract_stylesheets(sample_soup),
        extract_tiles(sample_soup),
        "Stand: 17:40 Uhr",
        "17:40 Uhr",
    )
    assert "mailster" not in html

def test_build_html_excludes_green(sample_soup):
    html = build_html(
        extract_stylesheets(sample_soup),
        extract_tiles(sample_soup),
        None, "17:40 Uhr",
    )
    assert "status-green" not in html

def test_build_html_contains_css_links(sample_soup):
    html = build_html(extract_stylesheets(sample_soup), [], None, "17:40 Uhr")
    assert 'rel="stylesheet"' in html

def test_write_output_creates_file(tmp_path):
    p = tmp_path / "out.html"
    write_output("<html/>", str(p))
    assert p.read_text() == "<html/>"

def test_fetch_page_uses_user_agent(requests_mock):
    requests_mock.get(URL, text="<html/>")
    fetch_page(URL)
    assert "Mozilla" in requests_mock.last_request.headers["User-Agent"]

def test_fetch_page_raises_on_http_error(requests_mock):
    requests_mock.get(URL, status_code=503)
    with pytest.raises(requests.HTTPError):
        fetch_page(URL)
```

**Quality gates:**
- `pytest tests/` with >90% coverage
- `ruff check hvv_scraper.py tests/`
- `mypy hvv_scraper.py`

---

## Verification

| Acceptance criterion | Test / evidence |
|---|---|
| Popup removed | `test_build_html_excludes_mailster` |
| Only red + yellow tiles shown | `test_extract_tiles_returns_only_red_and_yellow`, `test_extract_tiles_excludes_green` |
| KPI spans not confused with tile cards | `test_extract_tiles_excludes_kpi_spans` |
| CSS preserved for correct rendering | `test_build_html_contains_css_links` |
| Timestamp visible in output | `test_extract_last_update_found` |
| Card renders in HA dashboard | Manual: add card, verify tiles appear with colour styling |
| Card refreshes without page reload | Manual: wait 5 min, verify updated timestamp |

---

## Forward Compatibility

| Potential downstream need | Integration point | Design now |
|---|---|---|
| Filter by specific line | `extract_tiles` signature | Accept `lines: list[str] \| None = None`; filter by `data-line-key` attribute when set |
| Push notification on new red tile | `build_html` + separate notifier | Tile list returned by `extract_tiles` is plain Python; trivial to compare with previous run |
| Offline CSS (no internet) | `build_html` | `--inline-css` flag: fetch and inline stylesheets before writing |

---

## Dependency Changes

**`requirements.txt`:**
```
requests>=2.32
beautifulsoup4>=4.12
lxml>=5.0
```

**Dev / test:**
```
pytest>=8.0
pytest-requests-mock>=1.12
ruff>=0.4
mypy>=1.10
```

Python 3.11+ (available on all current HA OS versions).

---

## Key References

| Resource | Path / URL | Relevance |
|---|---|---|
| Target page | `https://www.nahverkehrhamburg.de/hvv-stoerungen-heute/` | Source of disruption data |
| Tile CSS selector | `.hvv-line-card.status-red`, `.hvv-line-card.status-yellow` | Filter selector |
| Popup selector | `.mailster-block-form-type-popup` | Excluded from output |
| Update timestamp | `.last-update-notice` | Preserved in output |
| HA `www` folder | `/config/www/` → `/local/` | Serving the pre-filtered HTML |
| HA shell_command docs | https://www.home-assistant.io/integrations/shell_command/ | Scheduling the scraper |
| HA custom cards guide | https://developers.home-assistant.io/docs/frontend/custom-ui/custom-card/ | Card registration |
