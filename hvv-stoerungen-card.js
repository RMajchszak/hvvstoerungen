class HvvStoerungsCard extends HTMLElement {
  _intervalMs = 300_000;

  setConfig(config) {
    const secs = Number(config.refresh_interval ?? 300);
    if (!Number.isFinite(secs) || secs < 10) {
      throw new Error("refresh_interval must be a finite number ≥ 10");
    }
    this._intervalMs = secs * 1000;
  }

  set hass(_) {
    if (!this._started) {
      this._started = true;
      this._render();
      this._timer = setInterval(() => this._render(), this._intervalMs);
    }
  }

  async _render() {
    if (this._rendering) return;
    this._rendering = true;
    try {
      const resp = await fetch(`/local/hvv_tiles.html?_=${Date.now()}`);
      if (!resp.ok) throw new Error(`HTTP ${resp.status} ${resp.statusText}`);
      this.innerHTML = await resp.text();
    } catch (e) {
      this.innerHTML = `<p style="padding:8px;color:#c62828;font-family:sans-serif">
        HVV-Daten nicht verfügbar: ${e.message}
      </p>`;
    } finally {
      this._rendering = false;
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
