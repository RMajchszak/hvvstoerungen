# HVV Störungen — Installationsanleitung

Zeigt nur die gelben und roten Störungsmeldungen des HVV als Custom Lovelace Card
im Home Assistant Dashboard. Kein Add-on erforderlich.

## Funktionsweise

```
HA Automation (alle 5 min)
  → shell_command: python3 hvv_scraper.py
      → schreibt /config/www/hvv_tiles.html
          → Lovelace Card liest /local/hvv_tiles.html
              → zeigt gefilterte Kacheln im Dashboard
```

Das Popup und alle grünen Kacheln werden herausgefiltert.
Die Original-CSS der HVV-Seite wird eingebunden, damit das Styling erhalten bleibt.

---

## Installation

### 1. Dateien auf den HA-Host kopieren

```bash
cp hvv_scraper.py         /config/hvv_scraper.py
mkdir -p /config/www
cp hvv-stoerungen-card.js /config/www/hvv-stoerungen-card.js
```

### 2. Python-Abhängigkeiten installieren

Im Terminal-Add-on oder per SSH:

```bash
pip3 install requests beautifulsoup4 lxml
```

### 3. configuration.yaml ergänzen

Inhalte aus `configuration_snippet.yaml` in `/config/configuration.yaml` einfügen.
Vorhandene `shell_command:`, `automation:` und `lovelace:` Blöcke
zusammenführen — nicht doppelt anlegen.

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

lovelace:
  resources:
    - url: /local/hvv-stoerungen-card.js
      type: module
```

**Alternativ** (Lovelace im UI-Modus):
Settings → Dashboards → Resources → Add resource
URL: `/local/hvv-stoerungen-card.js` · Type: JavaScript module

### 4. Home Assistant neu starten

Developer Tools → Restart Home Assistant

### 5. Ersten Abruf manuell auslösen

Developer Tools → Services → `shell_command.hvv_scraper` → Call Service

### 6. Card zum Dashboard hinzufügen

Dashboard bearbeiten → Card hinzufügen → Manual:

```yaml
type: custom:hvv-stoerungen-card
```

Optionale Einstellung:

```yaml
type: custom:hvv-stoerungen-card
refresh_interval: 300   # Sekunden (Standard: 300 = 5 Minuten)
```

---

## Dateien

| Datei | Ziel auf HA-Host | Beschreibung |
|---|---|---|
| `hvv_scraper.py` | `/config/hvv_scraper.py` | Python-Scraper |
| `hvv-stoerungen-card.js` | `/config/www/hvv-stoerungen-card.js` | Lovelace Card |
| `ha_config/configuration_snippet.yaml` | in `/config/configuration.yaml` mergen | HA-Konfiguration |
| `requirements.txt` | — | Python-Abhängigkeiten |

---

## Scraper manuell testen

```bash
python3 hvv_scraper.py --output /tmp/test.html
open /tmp/test.html          # macOS
xdg-open /tmp/test.html      # Linux
```

## Unit-Tests ausführen

```bash
uv run --with requests --with beautifulsoup4 --with lxml \
       --with pytest --with requests-mock \
       pytest tests/ -v
```
