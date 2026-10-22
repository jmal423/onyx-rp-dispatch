(() => {
  const radioFields = document.getElementById('radioFields');
  if (!radioFields) return;

  const storageKey = 'onyx_dispatch.unit_filters.v1';
  const jobs = ['police', 'sheriff', 'ambulance'];
  const labels = { police: 'LSPD', sheriff: 'Sheriff', ambulance: 'EMS' };
  const visible = { police: true, sheriff: true, ambulance: true };
  const jobsByPlayerId = new Map();
  let viewerJob = null;

  try {
    const saved = JSON.parse(localStorage.getItem(storageKey) || '{}');
    for (const job of jobs) {
      if (typeof saved[job] === 'boolean') visible[job] = saved[job];
    }
  } catch (_) {
    // Definições inválidas são ignoradas; todas as forças começam visíveis.
  }

  function normalizeJob(job) {
    if (job === 'bcso') return 'sheriff';
    return jobs.includes(job) ? job : null;
  }

  function isPoliceViewer() {
    const job = normalizeJob(viewerJob);
    return job === 'police' || job === 'sheriff';
  }

  function createFilterBar() {
    let bar = document.getElementById('onyxUnitFilters');
    if (bar || !isPoliceViewer()) return bar;

    bar = document.createElement('div');
    bar.id = 'onyxUnitFilters';
    bar.setAttribute('aria-label', 'Filtrar unidades por força');

    const label = document.createElement('span');
    label.className = 'small text-muted align-self-center';
    label.textContent = 'Mostrar na lista:';
    bar.appendChild(label);

    for (const job of jobs) {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'onyx-unit-filter-button';
      button.dataset.job = job;
      button.textContent = labels[job];
      button.addEventListener('click', () => {
        visible[job] = !visible[job];
        button.setAttribute('aria-pressed', String(visible[job]));
        try {
          localStorage.setItem(storageKey, JSON.stringify(visible));
        } catch (_) {
          // O filtro continua funcional nesta sessão se o armazenamento falhar.
        }
        applyFilters();
      });
      bar.appendChild(button);
    }

    radioFields.parentElement.insertBefore(bar, radioFields);
    return bar;
  }

  function isJobVisible(job) {
    const normalized = normalizeJob(job);
    if (!normalized) return true;
    if (normalizeJob(viewerJob) === 'ambulance') return normalized === 'ambulance';
    return visible[normalized] !== false;
  }

  function applyFilters() {
    const bar = createFilterBar();
    if (bar) {
      for (const button of bar.querySelectorAll('[data-job]')) {
        button.setAttribute('aria-pressed', String(visible[button.dataset.job] !== false));
      }
    }

    for (const unit of radioFields.querySelectorAll('.unit[data-player-id]')) {
      const job = jobsByPlayerId.get(unit.dataset.playerId);
      if (!job) continue;
      unit.dataset.onyxJob = job;
      unit.classList.toggle('onyx-unit-filter-hidden', !isJobVisible(job));
    }

    for (const group of radioFields.querySelectorAll('.unit-group:not(.unit-group-create)')) {
      const units = group.querySelectorAll('.unit[data-player-id][data-onyx-job]');
      if (units.length === 0) {
        group.classList.remove('onyx-unit-group-filter-hidden');
        continue;
      }
      const hasVisibleUnit = [...units].some((unit) => !unit.classList.contains('onyx-unit-filter-hidden'));
      group.classList.toggle('onyx-unit-group-filter-hidden', !hasVisibleUnit);
    }
  }

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || data.action !== 'showlarge_ui') return;

    viewerJob = typeof data.job === 'string' ? data.job : null;
    jobsByPlayerId.clear();
    if (Array.isArray(data.large_uidata)) {
      for (const unit of data.large_uidata) {
        if (!unit || unit.id === undefined || typeof unit.job !== 'string') continue;
        jobsByPlayerId.set(String(unit.id), unit.job);
      }
    }
    applyFilters();
  });

  const observer = new MutationObserver(() => {
    applyFilters();
  });

  observer.observe(radioFields, { childList: true, subtree: true });
})();
