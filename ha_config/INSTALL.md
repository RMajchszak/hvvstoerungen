# HVV Störungen — Installationsanleitung

Zeigt nur die gelben und roten Störungsmeldungen des HVV als Custom Lovelace Card
im Home Assistant Dashboard. Kein Add-on, kein Terminal-Zugang erforderlich.

## Funktionsweise

```
pyscript (läuft alle 5 min automatisch via @time_trigger)
  → hvv_scraper.py fetcht nahverkehrhamburg.de
      → schreibt /config/www/hvv_tiles.html
          → Lovelace Card liest /local/hvv_tiles.html
              → zeigt gefilterte Kacheln im Dashboard
```

Das Popup und alle grünen Kacheln werden herausgefiltert.
Die Original-CSS der HVV-Seite wird eingebunden, damit das Styling erhalten bleibt.

Das Skript verwendet ausschließlich Python-Standardbibliotheken (`urllib`, `re`, `os`) —
es müssen **keine Pakete per pip installiert** werden.

---

## Voraussetzung: HACS installieren

Falls HACS noch nicht installiert ist:
→ https://hacs.xyz/docs/use/download/download/

---

## Installation

### 1. pyscript via HACS installieren

1. HACS → Integrations → Explore & Download Repositories
2. Suche nach **pyscript**
3. Download → Restart Home Assistant

### 2. Dateien anlegen

Über den **File Editor** (oder Studio Code Server) Add-on:

| Quelldatei | Ziel in HA |
|---|---|
| `ha_config/hvv_pyscript.py` | `/config/pyscript/hvv_scraper.py` |
| `hvv-stoerungen-card.js` | `/config/www/hvv-stoerungen-card.js` |

Den Ordner `/config/pyscript/` anlegen, falls er noch nicht existiert.
Den Ordner `/config/www/` anlegen, falls er noch nicht existiert.

### 3. configuration.yaml ergänzen

Inhalte aus `configuration_snippet.yaml` in `/config/configuration.yaml` einfügen.
Vorhandenen `lovelace:` Block zusammenführen — nicht doppelt anlegen.

```yaml
pyscript:
  allow_all_imports: true

lovelace:
  resources:
    - url: /local/hvv-stoerungen-card.js
      type: module
```

> **Lovelace im UI-Modus** (kein YAML-Lovelace):
> Settings → Dashboards → Resources → Add resource
> URL: `/local/hvv-stoerungen-card.js` · Type: JavaScript module

### 4. Home Assistant neu starten

Developer Tools → Restart Home Assistant

### 5. Ersten Abruf manuell auslösen

Developer Tools → Actions → Action: `pyscript.hvv_scraper` → Perform Action

Danach sollte `/config/www/hvv_tiles.html` existieren.

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

## Automatische Aktualisierung

Keine weitere Konfiguration nötig. Das Skript enthält `@time_trigger("cron(*/5 * * * *)")`
und läuft automatisch alle 5 Minuten, sobald pyscript gestartet ist.

---

## Dateien

| Datei | Ziel in HA | Beschreibung |
|---|---|---|
| `ha_config/hvv_pyscript.py` | `/config/pyscript/hvv_scraper.py` | Scraper (pyscript, nur stdlib) |
| `hvv-stoerungen-card.js` | `/config/www/hvv-stoerungen-card.js` | Lovelace Card |
| `ha_config/configuration_snippet.yaml` | in `/config/configuration.yaml` mergen | pyscript + Lovelace Ressource |

---

## Fehlersuche

Logs ansehen: Settings → System → Logs → Filter nach `hvv`

Häufige Ursachen:
- `/config/pyscript/` existiert nicht → Ordner anlegen, HA neu starten
- pyscript nicht aktiv → `pyscript:` fehlt in `configuration.yaml`
- `/config/www/` existiert nicht → wird beim ersten Lauf automatisch erstellt
