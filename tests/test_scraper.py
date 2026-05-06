"""Unit tests for hvv_scraper.py."""

from __future__ import annotations

from pathlib import Path

import pytest
import requests
from bs4 import BeautifulSoup

import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from hvv_scraper import (
    URL,
    build_html,
    extract_last_update,
    extract_stylesheets,
    extract_tiles,
    fetch_page,
    write_output,
)

FIXTURE = Path(__file__).parent / "fixtures" / "page_sample.html"


@pytest.fixture
def sample_soup() -> BeautifulSoup:
    return BeautifulSoup(FIXTURE.read_text(encoding="utf-8"), "lxml")


@pytest.fixture
def empty_soup() -> BeautifulSoup:
    return BeautifulSoup("<html><body></body></html>", "lxml")


# --- extract_tiles -----------------------------------------------------------

def test_extract_tiles_returns_only_red_and_yellow(sample_soup):
    tiles = extract_tiles(sample_soup)
    assert len(tiles) == 3  # 2 red + 1 yellow


def test_extract_tiles_excludes_green(sample_soup):
    tiles = extract_tiles(sample_soup)
    for t in tiles:
        assert "status-green" not in t.get("class", [])


def test_extract_tiles_excludes_kpi_spans(sample_soup):
    # KPI value spans carry status-red/yellow but are not hvv-line-card divs
    tiles = extract_tiles(sample_soup)
    for t in tiles:
        assert "hvv-line-card" in t.get("class", [])


def test_extract_tiles_empty_page(empty_soup):
    assert extract_tiles(empty_soup) == []


# --- extract_stylesheets -----------------------------------------------------

def test_extract_stylesheets_returns_link_tags(sample_soup):
    sheets = extract_stylesheets(sample_soup)
    assert len(sheets) == 2
    for s in sheets:
        assert s.name == "link"


def test_extract_stylesheets_empty_page(empty_soup):
    assert extract_stylesheets(empty_soup) == []


# --- extract_last_update -----------------------------------------------------

def test_extract_last_update_found(sample_soup):
    text = extract_last_update(sample_soup)
    assert text is not None
    assert "Stand:" in text


def test_extract_last_update_missing(empty_soup):
    assert extract_last_update(empty_soup) is None


# --- build_html --------------------------------------------------------------

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
        None,
        "17:40 Uhr",
    )
    assert "status-green" not in html


def test_build_html_contains_css_links(sample_soup):
    html = build_html(extract_stylesheets(sample_soup), [], None, "17:40 Uhr")
    assert 'rel="stylesheet"' in html


def test_build_html_contains_fetched_at(sample_soup):
    html = build_html([], [], None, "17:40 Uhr")
    assert "17:40 Uhr" in html


def test_build_html_contains_last_update(sample_soup):
    html = build_html([], [], "Stand: 17:40 Uhr", "17:40 Uhr")
    assert "Stand: 17:40 Uhr" in html


def test_build_html_with_no_last_update(sample_soup):
    # Should not crash when last_update is None
    html = build_html([], [], None, "17:40 Uhr")
    assert "abgerufen" in html


# --- write_output ------------------------------------------------------------

def test_write_output_creates_file(tmp_path):
    p = tmp_path / "out.html"
    write_output("<html/>", str(p))
    assert p.read_text() == "<html/>"


def test_write_output_overwrites_existing(tmp_path):
    p = tmp_path / "out.html"
    p.write_text("old")
    write_output("new", str(p))
    assert p.read_text() == "new"


# --- fetch_page --------------------------------------------------------------

def test_fetch_page_uses_user_agent(requests_mock):
    requests_mock.get(URL, text="<html/>")
    fetch_page(URL)
    assert "Mozilla" in requests_mock.last_request.headers["User-Agent"]


def test_fetch_page_raises_on_http_error(requests_mock):
    requests_mock.get(URL, status_code=503)
    with pytest.raises(requests.HTTPError):
        fetch_page(URL)


def test_fetch_page_raises_on_404(requests_mock):
    requests_mock.get(URL, status_code=404)
    with pytest.raises(requests.HTTPError):
        fetch_page(URL)
