// layout.js — Injects shared sidebar, topbar theme toggle, and handles logout

import { logout } from './auth.js';
import { initTheme, toggleTheme } from './theme.js';

// Active nav detection
function getActivePage() {
  return window.location.pathname.split('/').pop() || 'dashboard.html';
}

const NAV_ITEMS = [
  { page: 'dashboard.html', icon: '🏠', label: 'Dashboard' },
  { page: 'students.html', icon: '👨‍🎓', label: 'Students' },
  { page: 'teachers.html', icon: '👩‍🏫', label: 'Teachers' },
  { page: 'classes.html', icon: '🏫', label: 'Classes' },
  { page: 'subjects.html', icon: '📚', label: 'Subjects' },
  { page: 'timetable.html', icon: '📅', label: 'Timetable' },
  { page: 'exams.html', icon: '📝', label: 'Exams' },
  { page: 'attendance.html', icon: '✅', label: 'Attendance' },
  { page: 'complaints.html', icon: '⚠️', label: 'Complaints' },
  { page: 'notifications.html', icon: '🔔', label: 'Notifications' },
];

export function injectSidebar(userEmail = '') {
  const active = getActivePage();
  const avatarLetter = userEmail ? userEmail[0].toUpperCase() : 'A';

  const navHtml = NAV_ITEMS.map(item => `
    <a class="nav-item ${item.page === active ? 'active' : ''}" href="${item.page}">
      <span style="font-size:15px;">${item.icon}</span> ${item.label}
    </a>
  `).join('');

  const sidebar = document.querySelector('.sidebar');
  if (!sidebar) return;

  sidebar.innerHTML = `
    <div class="sidebar-header">
      <div class="logo-icon">🎓</div>
      <div class="brand"><h2>EduManage</h2><p>Admin Portal</p></div>
    </div>
    <nav class="sidebar-nav">
      <div class="nav-section">${navHtml}</div>
    </nav>
    <div class="sidebar-footer">
      <div class="sidebar-user">
        <div class="avatar" id="user-avatar">${avatarLetter}</div>
        <div class="user-info">
          <p id="user-email" style="font-size:11px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:130px;">${userEmail || 'Admin'}</p>
          <p>Administrator</p>
        </div>
      </div>
      <button class="btn-logout" id="logout-btn">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
          <polyline points="16 17 21 12 16 7"/>
          <line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        Sign Out
      </button>
    </div>
  `;

  document.getElementById('logout-btn')?.addEventListener('click', () => logout());
}

export function injectTopbarToggle() {
  const right = document.getElementById('topbar-right');
  if (!right) return;

  const btn = document.createElement('button');
  btn.className = 'theme-toggle-btn';
  btn.title = 'Toggle Theme';
  btn.onclick = toggleTheme;
  btn.innerHTML = `
    <span class="theme-icon-light" style="display:none;">
      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="5"/>
        <line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/>
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
        <line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/>
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
      </svg>
    </span>
    <span class="theme-icon-dark">
      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
      </svg>
    </span>
  `;
  right.prepend(btn);
  // Re-sync icons with current theme
  initTheme();
}
