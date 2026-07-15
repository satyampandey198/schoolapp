// theme.js — Light/Dark theme engine for Admin Portal

const THEME_KEY = 'edumanage_theme';

// ── Apply theme ───────────────────────────────────────────────
export function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem(THEME_KEY, theme);
  // Update toggle icons everywhere
  document.querySelectorAll('.theme-icon-dark').forEach(el => el.style.display = theme === 'dark' ? 'none' : 'block');
  document.querySelectorAll('.theme-icon-light').forEach(el => el.style.display = theme === 'dark' ? 'block' : 'none');
  document.querySelectorAll('.theme-toggle-btn').forEach(btn => {
    btn.title = theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode';
  });
}

// ── Toggle ────────────────────────────────────────────────────
export function toggleTheme() {
  const current = localStorage.getItem(THEME_KEY) || 'dark';
  applyTheme(current === 'dark' ? 'light' : 'dark');
}

// ── Initialize ────────────────────────────────────────────────
export function initTheme() {
  const saved = localStorage.getItem(THEME_KEY) || 'dark';
  applyTheme(saved);
}

// ── Inject Toggle Button into Topbar ─────────────────────────
export function injectToggleButton(containerId = 'topbar-right') {
  const container = document.getElementById(containerId);
  if (!container) return;
  const btn = document.createElement('button');
  btn.className = 'theme-toggle-btn';
  btn.onclick = toggleTheme;
  btn.title = 'Toggle theme';
  btn.innerHTML = `
    <span class="theme-icon-light" style="display:none;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/>
        <line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/>
        <line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
      </svg>
    </span>
    <span class="theme-icon-dark">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
      </svg>
    </span>
  `;
  container.prepend(btn);
  // Re-apply to update button icons
  applyTheme(localStorage.getItem(THEME_KEY) || 'dark');
}

// Auto-init on any page that imports this module
document.addEventListener('DOMContentLoaded', initTheme);
