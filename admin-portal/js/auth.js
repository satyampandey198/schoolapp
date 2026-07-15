// auth.js — Handles login, logout, and session guard
import { auth } from './firebase-config.js';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";

// Guard: redirect to login if not authenticated
export function requireAuth(callback) {
  onAuthStateChanged(auth, (user) => {
    if (!user) {
      window.location.href = 'index.html';
    } else {
      callback(user);
    }
  });
}

// Guard: redirect to dashboard if already logged in
export function redirectIfLoggedIn() {
  onAuthStateChanged(auth, (user) => {
    if (user) window.location.href = 'dashboard.html';
  });
}

// Login
export async function loginWithEmail(email, password) {
  return signInWithEmailAndPassword(auth, email, password);
}

// Logout
export async function logout() {
  await signOut(auth);
  window.location.href = 'index.html';
}

// Get current user
export function currentUser() {
  return auth.currentUser;
}
