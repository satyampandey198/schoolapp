// app.js — Shared utilities for Admin Portal

// ── Toast Notifications ──────────────────────────────────────
export function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container') || createToastContainer();
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  const icons = { success: '✓', error: '✕', info: 'ℹ' };
  toast.innerHTML = `<span>${icons[type] || '●'}</span><span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => { toast.style.opacity = '0'; toast.style.transform = 'translateX(40px)'; toast.style.transition = 'all 0.3s'; setTimeout(() => toast.remove(), 300); }, 3000);
}

function createToastContainer() {
  const el = document.createElement('div');
  el.id = 'toast-container';
  el.className = 'toast-container';
  document.body.appendChild(el);
  return el;
}

// ── Loading State ────────────────────────────────────────────
export function setLoading(btnEl, isLoading, loadingText = 'Saving...') {
  if (isLoading) {
    btnEl._originalText = btnEl.innerHTML;
    btnEl.innerHTML = `<span class="spinner" style="width:16px;height:16px;border-width:2px;display:inline-block;"></span> ${loadingText}`;
    btnEl.disabled = true;
  } else {
    btnEl.innerHTML = btnEl._originalText || 'Submit';
    btnEl.disabled = false;
  }
}

// ── Modal Control ────────────────────────────────────────────
export function openModal(id) { document.getElementById(id)?.classList.add('open'); }
export function closeModal(id) { document.getElementById(id)?.classList.remove('open'); }

// Close modal on overlay click
document.addEventListener('click', (e) => {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('open');
  }
});

// ── Format Date ──────────────────────────────────────────────
export function formatDate(ts) {
  if (!ts) return '—';
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

// ── Avatars ──────────────────────────────────────────────────
const COLORS = ['#6366f1','#0ea5e9','#10b981','#f59e0b','#ef4444','#8b5cf6','#ec4899'];
export function getAvatarColor(name = '') {
  let sum = 0; for (const c of name) sum += c.charCodeAt(0);
  return COLORS[sum % COLORS.length];
}
export function getInitials(name = '') {
  return name.split(' ').slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('');
}
export function avatarHtml(name, size = 32) {
  const color = getAvatarColor(name);
  return `<div class="avatar-sm" style="background:${color};width:${size}px;height:${size}px;">${getInitials(name)}</div>`;
}

// ── Nav Active State ─────────────────────────────────────────
export function setActiveNav() {
  const path = window.location.pathname.split('/').pop();
  document.querySelectorAll('.nav-item[data-page]').forEach(el => {
    el.classList.toggle('active', el.dataset.page === path);
  });
}

// ── Confirm Dialog ───────────────────────────────────────────
export function confirmDialog(message) {
  return window.confirm(message);
}

// ── Sidebar toggle (mobile) ──────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.getElementById('sidebar-toggle');
  const sidebar = document.querySelector('.sidebar');
  if (toggle && sidebar) {
    toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
  }
  setActiveNav();
});
