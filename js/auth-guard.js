
import { initializeApp, getApps, getApp } from "https://www.gstatic.com/firebasejs/13.0.0/firebase-app.js";
import {
    getAuth,
    onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-auth.js";

console.log("AUTH-GUARD: archivo cargado");

const firebaseConfig = {
    apiKey: "AIzaSyBvImqStihYvhWGFEdCzBnWr4HiI_49BIc",
    authDomain: "observador-virtual.firebaseapp.com",
    projectId: "observador-virtual",
    storageBucket: "observador-virtual.firebasestorage.app",
    messagingSenderId: "168537175075",
    appId: "1:168537175075:web:fc0df9eb3c7d26f0e2ad96",
    measurementId: "G-2E21RDST23"
};

const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const auth = getAuth(app);

const paginasPublicas = [
    "index.html",
    "login.html",
    "registro.html",
];

const paginaActual = window.location.pathname
    .split("/")
    .pop()
    .toLowerCase();

console.log("AUTH-GUARD: página actual:", paginaActual);

if (!paginasPublicas.includes(paginaActual)) {
    document.documentElement.style.visibility = "hidden";

    onAuthStateChanged(auth, (usuario) => {
        console.log(
            "AUTH-GUARD: usuario autenticado:",
            Boolean(usuario)
        );

        if (!usuario || !usuario.emailVerified) {
            const rutaLogin = new URL("login.html", window.location.href);
            window.location.replace(rutaLogin.href);
            return;
        }

        document.documentElement.style.visibility = "visible";
    });
}
