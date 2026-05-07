"""HVV Störungen scraper for the pyscript integration.

Place this file at:  /config/pyscript/hvv_scraper.py

Runs automatically every 5 minutes via @time_trigger.
Trigger manually via Developer Tools → Actions → pyscript.hvv_scraper.
Uses only Python stdlib — no pip packages required.
"""

import os
import re
import urllib.request
from datetime import datetime
from html import escape

URL = "https://www.nahverkehrhamburg.de/hvv-stoerungen-heute/"
OUTPUT = "/config/www/hvv_tiles.html"
HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; hvvstoerungen/1.0)"}


def _fetch(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=15) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _extract_stylesheets(html):
    return re.findall(
        r'<link[^>]+rel=["\']stylesheet["\'][^>]*/?\s*>',
        html,
        re.IGNORECASE,
    )


def _extract_tiles(html):
    """Extract hvv-line-card divs with status-red or status-yellow.

    Uses depth counting to find matching </div> for each opening tag,
    since BeautifulSoup is not available in this environment.
    """
    tiles = []
    pattern = re.compile(
        r'<div\s[^>]*class="[^"]*hvv-line-card[^"]*status-(?:red|yellow)[^"]*"',
        re.IGNORECASE,
    )
    for match in pattern.finditer(html):
        start = match.start()
        pos, depth = start, 0
        while pos < len(html):
            nxt_open = html.find("<div", pos)
            nxt_close = html.find("</div>", pos)
            if nxt_close == -1:
                break
            if nxt_open != -1 and nxt_open < nxt_close:
                depth += 1
                pos = nxt_open + 4
            else:
                depth -= 1
                end = nxt_close + 6
                pos = end
                if depth == 0:
                    tiles.append(html[start:end])
                    break
    return tiles


def _extract_last_update(html):
    m = re.search(r'class="last-update-notice"[^>]*>(.*?)</p>', html, re.DOTALL)
    if m:
        return re.sub(r"<[^>]+>", "", m.group(1)).strip()
    return None


def _build_html(stylesheets, tiles, last_update):
    css = "\n".join(stylesheets)
    tile_html = "\n".join(tiles)
    update_text = escape(last_update or "")
    fetched_at = escape(datetime.now().strftime("%H:%M Uhr"))
    update_line = f"<p class='update-notice'>{update_text} · abgerufen {fetched_at}</p>"
    return f"""<!DOCTYPE html>
<html lang="de">
<head><meta charset="UTF-8">
{css}
<style>
  body {{ margin: 0; background: transparent; }}
  .tile-grid {{ display: flex; flex-wrap: wrap; gap: 8px; padding: 8px; }}
  .update-notice {{ font-size: 0.75rem; color: #888; padding: 4px 8px; }}
</style>
</head>
<body>
  {update_line}
  <div class="tile-grid">
{tile_html}
  </div>
</body>
</html>"""


def _update():
    html = _fetch(URL)
    tiles = _extract_tiles(html)
    content = _build_html(_extract_stylesheets(html), tiles, _extract_last_update(html))
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write(content)
    log.info("HVV: Written %d tiles to %s", len(tiles), OUTPUT)


@time_trigger("cron(*/5 * * * *)")
@service
def hvv_scraper(**kwargs):
    """Fetch and filter HVV disruption tiles, write to /config/www/."""
    try:
        task.executor(_update)
    except Exception as exc:
        log.error("HVV: Failed to update tiles: %s", exc)
