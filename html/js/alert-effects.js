(() => {
  const header = document.getElementById('dispatchHeader');
  const content = document.getElementById('dispatchCallContent');
  const body = document.getElementById('body');
  const title = document.getElementById('title');
  const message = document.getElementById('message');

  if (!header || !content || !body || !title || !message) return;

  const updateAlertEffect = () => {
    const isActive = message.textContent.trim().length > 0;
    const isUrgent = /\b10\s*[-–]\s*99\b/i.test(title.textContent);

    header.classList.toggle('dispatch-alert-urgent', isActive && isUrgent);
    content.classList.toggle('dispatch-alert-normal', isActive && !isUrgent);
    content.classList.toggle('dispatch-alert-urgent', isActive && isUrgent);
  };

  new MutationObserver(updateAlertEffect).observe(body, {
    childList: true,
    characterData: true,
    subtree: true,
  });

  updateAlertEffect();
})();
