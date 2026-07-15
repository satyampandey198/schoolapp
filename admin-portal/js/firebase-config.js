// firebase-config.js — Firebase connection for Admin Portal
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyDaEbUKLYGEYGVLlhjypVfOFFjCEKHqxTg",
  authDomain: "school-app-csdese.firebaseapp.com",
  projectId: "school-app-csdese",
  storageBucket: "school-app-csdese.firebasestorage.app",
  messagingSenderId: "1006897282967",
  appId: "1:1006897282967:web:f8295ac50f6e5eb5448ed2",
  measurementId: "G-488YW63WMP"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
