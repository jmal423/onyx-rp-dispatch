(() => {
  const input = document.getElementById('set-callsign');
  const modal = document.getElementById('settingsModal');

  if (!input || !modal || typeof window.jQuery !== 'function') return;

  let currentPlayerSource = null;
  let currentCallsign = '';

  const applyCallsign = (callsign) => {
    if (typeof callsign !== 'string') return;

    currentCallsign = callsign;
    if (document.activeElement !== input) input.value = callsign;
  };

  window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message || typeof message !== 'object') return;

    if (message.action === 'currentplayer' && message.values) {
      currentPlayerSource = message.values.source ?? null;
      applyCallsign(message.values.callsign ?? '');
      return;
    }

    if (
      message.action === 'syncusersettings' &&
      message.values &&
      currentPlayerSource !== null &&
      String(message.values.source) === String(currentPlayerSource)
    ) {
      applyCallsign(message.values.callsign ?? '');
    }
  });

  window.jQuery(modal).on('show.bs.modal', () => {
    if (input.value.trim() === '' && currentCallsign !== '') {
      input.value = currentCallsign;
    }
  });
})();
