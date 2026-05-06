class HvvStoerungsCard extends HTMLElement {
  setConfig(config) {
    this._intervalMs = (config.refresh_interval ?? 300) * 1000;
  }

  set hass(_) {
    if (!this._started) {
      this._started = true;
      this._render();
      this._timer = setInterval(() => this._render(), this._intervalMs);
    }
  }

  async _render() {
    try {
      const resp = await fetch(`/local/hvv_tiles.html?_=${Date.now()}`);
      if (!resp.ok) throw new Error(`HTTP ${resp.status} ${resp.statusText}`);
      const html = await resp.text();
      this.innerHTML = html;
    } catch (e) {
      this.innerHTML = `<p style="padding:8px;color:#c62828;font-family:sans-serif">
        HVV-Daten nicht verfügbar: ${e.message}
      </p>`;
    }
  }

  disconnectedCallback() {
    clearInterval(this._timer);
  }

  getCardSize() {
    return 3;
  }
}

customElements.define("hvv-stoerungen-card", HvvStoerungsCard);
