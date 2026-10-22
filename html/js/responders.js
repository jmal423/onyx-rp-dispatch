(() => {
  const snapshots = new Map();

  function renderSnapshot(count, snapshot) {
    const container = document.getElementById(`responding-units-${count}`);
    if (!container) return;

    const signature = JSON.stringify(snapshot.responders);
    const renderedRows = container.querySelectorAll('[data-onyx-responder-row]').length;
    const isAlreadyRendered = snapshot.responders.length === 0
      ? container.childNodes.length === 0
      : renderedRows === snapshot.responders.length && container.childElementCount === snapshot.responders.length;
    if (container.dataset.onyxResponderSignature === signature && isAlreadyRendered) return;

    container.replaceChildren();
    for (const responder of snapshot.responders) {
      const row = document.createElement('div');
      row.className = 'd-flex justify-content-between align-items-center';
      row.dataset.onyxResponderRow = 'true';

      const identity = document.createElement('span');
      identity.textContent = [responder.callsign, responder.name].filter(Boolean).join(' ');

      const distance = document.createElement('span');
      const metres = Number(responder.distance);
      distance.className = 'ml-2 text-nowrap';
      distance.textContent = Number.isFinite(metres)
        ? `${new Intl.NumberFormat('pt-PT').format(metres)} m`
        : '— m';

      row.append(identity, distance);
      container.appendChild(row);
    }
    container.dataset.onyxResponderSignature = signature;
  }

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || data.action !== 'responders_snapshot' || !Number.isInteger(data.count) ||
        !Array.isArray(data.responders)) return;

    const snapshot = {
      uniqueId: data.unique_id,
      responders: data.responders,
    };
    snapshots.set(data.count, snapshot);
    renderSnapshot(data.count, snapshot);
  });

  const observer = new MutationObserver(() => {
    snapshots.forEach((snapshot, count) => renderSnapshot(count, snapshot));
  });

  observer.observe(document.body, { childList: true, subtree: true });
})();
