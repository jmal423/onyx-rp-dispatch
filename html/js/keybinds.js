(() => {
  const keyElements = new Map(
    [...document.querySelectorAll('[data-keybind]')].map((element) => [
      element.dataset.keybind,
      element,
    ]),
  );

  window.addEventListener('message', (event) => {
    if (event.data?.action !== 'dispatchKeybinds' || !event.data.keys) return;

    for (const [name, element] of keyElements) {
      const key = event.data.keys[name];
      if (typeof key === 'string') element.textContent = key;
    }
  });

  fetch(`https://${GetParentResourceName()}/dispatchKeybindsReady`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({}),
  }).catch(() => {});
})();
