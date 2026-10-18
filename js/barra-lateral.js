
import {
    initializeApp,
    getApps,
    getApp
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-app.js";

import {
    getAuth,
    onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-auth.js";

import {
    getFirestore,
    doc,
    getDoc
} from "https://www.gstatic.com/firebasejs/13.0.0/firebase-firestore.js";

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
const db = getFirestore(app);

const roles = {
    estudiante: "Estudiante",
    acudiente: "Acudiente",
    rector: "Rector",
    coordinador: "Coordinador",
    cordinador: "Coordinador",
    orientador: "Orientador",
    profesor: "Profesor",
    docente: "Docente"
};

function textoValido(...valores) {
    for (const valor of valores) {
        if (typeof valor === "string" && valor.trim()) {
            return valor.trim();
        }
    }
    return "";
}

function normalizarRol(valor) {
    const rol = String(valor || "").trim().toLowerCase();
    return roles[rol] || (rol ? rol.charAt(0).toUpperCase() + rol.slice(1) : "");
}

function mostrarFoto(url) {
    const avatar = document.getElementById("ovAvatarUsuario");
    if (!avatar || !url) return;

    const imagen = document.createElement("img");
    imagen.alt = "Foto de perfil";
    imagen.referrerPolicy = "no-referrer";
    imagen.onerror = () => imagen.remove();
    imagen.src = url;

    avatar.replaceChildren(imagen);
}

onAuthStateChanged(auth, async usuario => {
    const nombreElemento = document.getElementById("ovNombreUsuario");
    const rolElemento = document.getElementById("ovRolUsuario");

    if (!nombreElemento || !rolElemento) return;

    if (!usuario) {
        nombreElemento.textContent = "Sin sesión";
        rolElemento.textContent = "No identificado";
        return;
    }

    nombreElemento.textContent =
        textoValido(usuario.displayName) ||
        textoValido(usuario.email?.split("@")[0]) ||
        "Usuario";

    rolElemento.textContent = "Consultando rol...";

    try {
        const referencia = doc(db, "usuarios", usuario.uid);
        const resultado = await getDoc(referencia);

        if (!resultado.exists()) {
            rolElemento.textContent = "Perfil no encontrado";
            return;
        }

        const datos = resultado.data();

        const nombreCompleto = textoValido(
            datos.nombreCompleto,
            datos.nombreYApellido,
            datos.nombre_completo
        );

        const nombres = textoValido(datos.nombre, datos.nombres);
        const apellidos = textoValido(datos.apellidos, datos.apellido);

        nombreElemento.textContent =
            nombreCompleto ||
            [nombres, apellidos].filter(Boolean).join(" ") ||
            textoValido(usuario.displayName) ||
            textoValido(usuario.email?.split("@")[0]) ||
            "Usuario";

        rolElemento.textContent = normalizarRol(
            datos.rol || datos.tipoUsuario || datos.tipoCuenta
        ) || "Rol no definido";

        mostrarFoto(textoValido(
            datos.fotoURL,
            datos.fotoPerfil,
            datos.photoURL,
            usuario.photoURL
        ));

        try {
            const sesion = JSON.parse(
                localStorage.getItem("sesionObservadorVirtual") || "{}"
            );

            localStorage.setItem("sesionObservadorVirtual", JSON.stringify({
                ...sesion,
                id: usuario.uid,
                nombre: nombreElemento.textContent,
                correo: usuario.email || "",
                rol: rolElemento.textContent
            }));
        } catch (error) {
            console.warn("No se pudo actualizar la sesión local.", error);
        }
    } catch (error) {
        console.error("Error al consultar el perfil:", error);
        rolElemento.textContent = "No disponible";
    }
});
