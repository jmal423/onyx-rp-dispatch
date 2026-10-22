(() => {
  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || data.action !== 'set_small_read_only') return;

    const buttonGroup = document.getElementById('buttonGroup');
    if (!buttonGroup) return;

    buttonGroup.classList.toggle('onyx-read-only', data.read_only === true);
  });
})();
