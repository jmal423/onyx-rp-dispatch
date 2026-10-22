(() => {
  function syncContextMenuReadOnly() {
    const menu = document.getElementById('context-menu');
    if (!menu) return;

    let isReadOnly = false;
    try {
      const items = typeof cdspg !== 'undefined' ? cdspg.items : null;
      const selectedCount = typeof cdspas !== 'undefined' ? Number(cdspas) : NaN;
      const selected = Array.isArray(items)
        ? (items[selectedCount] || items.find((item) => Number(item.count) === selectedCount))
        : null;
      isReadOnly = selected?.dispatcher_table?.read_only === true;
    } catch (_) {
      isReadOnly = false;
    }

    menu.classList.toggle('onyx-read-only', isReadOnly);
  }

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || data.action !== 'set_small_read_only') return;

    const buttonGroup = document.getElementById('buttonGroup');
    if (!buttonGroup) return;

    buttonGroup.classList.toggle('onyx-read-only', data.read_only === true);
  });

  document.addEventListener('contextmenu', () => {
    window.setTimeout(syncContextMenuReadOnly, 0);
  });
})();
