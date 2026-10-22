(() => {
  const content = document.getElementById('dispatchCallContent');
  const commands = document.getElementById('commands');
  const body = document.getElementById('body');
  const title = document.getElementById('title');
  const message = document.getElementById('message');

  if (!content || !commands || !body || !title || !message) return;

  const updateAlertEffect = () => {
    const isActive = message.textContent.trim().length > 0;
    const isUrgent = /\b10\s*[-–]\s*99\b/i.test(title.textContent);

    content.classList.toggle('dispatch-alert-normal', isActive && !isUrgent);
    content.classList.toggle('dispatch-alert-urgent', isActive && isUrgent);
    commands.classList.toggle('dispatch-alert-normal', isActive && !isUrgent);
    commands.classList.toggle('dispatch-alert-urgent', isActive && isUrgent);
  };

  new MutationObserver(updateAlertEffect).observe(body, {
    childList: true,
    characterData: true,
    subtree: true,
  });

  updateAlertEffect();
})();
