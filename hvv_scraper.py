"""Fetch and filter HVV disruption tiles for Home Assistant."""

from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

import requests
from bs4 import BeautifulSoup, Tag

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
        class_=lambda c: c is not None
        and "hvv-line-card" in c
        and ("status-red" in c or "status-yellow" in c),
    )


def extract_last_update(soup: BeautifulSoup) -> str | None:
    el = soup.find(class_="last-update-notice")
    return el.get_text(strip=True) if el else None


def build_html(
    stylesheets: list[Tag],
    tiles: list[Tag],
    last_update: str | None,
    fetched_at: str,
) -> str:
    css_links = "\n".join(str(tag) for tag in stylesheets)
    tile_html = "\n".join(str(t) for t in tiles)
    update_text = last_update or ""
    update_line = f"<p class='update-notice'>{update_text} · abgerufen {fetched_at}</p>"
    return f"""<!DOCTYPE html>
<html lang="de">
<head><meta charset="UTF-8">
{css_links}
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


def write_output(html: str, path: str) -> None:
    Path(path).write_text(html, encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Fetch filtered HVV disruption tiles")
    parser.add_argument(
        "--output",
        default="/config/www/hvv_tiles.html",
        help="Destination file path (default: /config/www/hvv_tiles.html)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        html = fetch_page(URL)
    except requests.RequestException as e:
        print(f"ERROR: Failed to fetch HVV page: {e}", file=sys.stderr)
        sys.exit(1)

    soup = BeautifulSoup(html, "lxml")
    tiles = extract_tiles(soup)
    output = build_html(
        extract_stylesheets(soup),
        tiles,
        extract_last_update(soup),
        datetime.now().strftime("%H:%M Uhr"),
    )
    try:
        write_output(output, args.output)
    except OSError as e:
        print(f"ERROR: Failed to write output: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Written {len(tiles)} tiles to {args.output}")


if __name__ == "__main__":
    main()
