(() => {
  let resizeTimer;
  let lastWidth = window.innerWidth;
  let lastHeight = window.innerHeight;
  let positionSaveTimer;
  const positionStorageKey = 'onyx_dispatch.small_relative_position.v1';
  let relativePosition = null;

  try {
    const saved = JSON.parse(localStorage.getItem(positionStorageKey) || 'null');
    if (saved && Number.isFinite(saved.x) && Number.isFinite(saved.y) &&
        saved.x >= 0 && saved.x <= 1 && saved.y >= 0 && saved.y <= 1) {
      relativePosition = { x: saved.x, y: saved.y };
    }
  } catch (_) {
    // Uma posição guardada inválida não impede o dispatch de abrir.
  }

  function notifyClient() {
    if (typeof GetParentResourceName !== 'function') return;

    fetch(`https://${GetParentResourceName()}/dispatchViewportChanged`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify({ width: window.innerWidth, height: window.innerHeight }),
    }).catch(() => {});
  }

  function refitMap() {
    const map = document.getElementById('map');
    if (!map || map.offsetParent === null) return;

    if (typeof window.resetMap === 'function') window.resetMap();
    if (typeof window.cdspaj === 'function') window.cdspaj(null, true);
  }

  function readRelativePosition() {
    const panel = document.getElementById('toastContainer');
    if (!panel || panel.getClientRects().length === 0 || window.innerWidth < 1 || window.innerHeight < 1) return;

    const rect = panel.getBoundingClientRect();
    if (rect.width < 1 || rect.height < 1) return;

    const maxLeft = Math.max(0, window.innerWidth - rect.width);
    const maxTop = Math.max(0, window.innerHeight - rect.height);
    relativePosition = {
      x: Math.min(1, Math.max(0, rect.left / Math.max(1, maxLeft))),
      y: Math.min(1, Math.max(0, rect.top / Math.max(1, maxTop))),
    };
  }

  function storeRelativePosition() {
    readRelativePosition();
    if (!relativePosition) return;
    try {
      localStorage.setItem(positionStorageKey, JSON.stringify(relativePosition));
    } catch (_) {
      // A posição mantém-se nesta sessão se o armazenamento estiver indisponível.
    }
  }

  function applyRelativePosition() {
    const panel = document.getElementById('toastContainer');
    if (!panel || panel.getClientRects().length === 0) return;

    if (!relativePosition) {
      readRelativePosition();
      storeRelativePosition();
      return;
    }

    const rect = panel.getBoundingClientRect();
    const maxLeft = Math.max(0, window.innerWidth - rect.width);
    const maxTop = Math.max(0, window.innerHeight - rect.height);
    const left = Math.min(maxLeft, Math.max(0, relativePosition.x * maxLeft));
    const top = Math.min(maxTop, Math.max(0, relativePosition.y * maxTop));

    panel.style.right = 'auto';
    panel.style.transform = 'none';
    panel.style.webkitTransform = 'none';
    panel.style.left = `${left}px`;
    panel.style.top = `${top}px`;
  }

  function schedulePositionSave() {
    clearTimeout(positionSaveTimer);
    positionSaveTimer = setTimeout(storeRelativePosition, 150);
  }

  const smallPanel = document.getElementById('toastContainer');
  if (smallPanel) {
    new MutationObserver(schedulePositionSave).observe(smallPanel, {
      attributes: true,
      attributeFilter: ['style'],
    });
  }

  window.addEventListener('message', (event) => {
    if (!event.data || event.data.action !== 'show_small') return;
    setTimeout(() => {
      if (relativePosition) applyRelativePosition();
      else storeRelativePosition();
    }, 0);
  });

  window.addEventListener('resize', () => {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(() => {
      if (lastWidth === window.innerWidth && lastHeight === window.innerHeight) return;
      lastWidth = window.innerWidth;
      lastHeight = window.innerHeight;

      refitMap();
      applyRelativePosition();
      notifyClient();
    }, 250);
  });
})();
