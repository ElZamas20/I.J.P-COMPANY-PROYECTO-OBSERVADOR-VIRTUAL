# OBSERVADOR VIRTUAL - I.J.P. Company
## Instrucciones de Instalación y Ejecución

---

## CONTENIDO DEL PROYECTO

```
observador_virtual/
├── INSTRUCCIONES.md          ← Este archivo
├── database/
│   └── observador_virtual.sql  ← Script de base de datos MySQL
├── css/
│   └── styles.css              ← Hoja de estilos principal
├── login.html                  ← Página de inicio de sesión
├── registro.html               ← Registro de nuevo usuario
├── recuperar-contrasena.html   ← Paso 1: Recuperar contraseña
├── verificar-codigo.html       ← Paso 2: Verificar código
├── nueva-contrasena.html       ← Paso 3: Ingresar nueva contraseña
├── exito-contrasena.html       ← Confirmación de cambio exitoso
├── dashboard.html              ← Página principal (home)
├── datos-personales.html       ← Subir documentos personales
├── info-contacto.html          ← Subir documentos de contacto
├── lista-estudiantes.html      ← Listado y búsqueda de estudiantes
├── observador-detalle.html     ← Observaciones del estudiante
├── observador-academico.html   ← Vista académica por período
└── registro.html               ← Formulario de registro
```

---

## PARTE 1 — ABRIR LA PÁGINA WEB (sin servidor)

El proyecto funciona directamente en el navegador **sin necesidad de instalar nada**.

### Pasos:

1. Descarga o descomprime la carpeta `observador_virtual/` en tu computador.
2. Navega hasta la carpeta en tu explorador de archivos.
3. Haz doble clic en el archivo **`login.html`**.
4. Se abrirá automáticamente en tu navegador predeterminado (Chrome, Firefox, Edge, etc.).

> **Nota:** Si la página no abre correctamente con doble clic, arrastra el archivo `login.html` directamente a la ventana de tu navegador.

### Credenciales de prueba (simuladas en el frontend):

| Usuario     | Contraseña    | Rol          |
|-------------|---------------|--------------|
| admin       | password123   | Admin        |
| prof_gomez  | password123   | Docente      |
| juan_perez  | password123   | Acudiente    |

> **Importante:** En esta versión estática, cualquier usuario/contraseña que ingreses accederá al dashboard. La validación real requiere el backend conectado a la base de datos.

---

## PARTE 2 — CONFIGURAR LA BASE DE DATOS MySQL

### Requisitos previos:

- Tener instalado **MySQL Server** (versión 5.7 o superior) o **XAMPP / WAMP / MAMP**.
- Tener acceso a **MySQL Workbench**, **phpMyAdmin** o la **línea de comandos** de MySQL.

---

### Opción A — Usando MySQL Workbench

1. Abre **MySQL Workbench** y conéctate a tu servidor local.
2. En el menú superior, ve a: `File → Open SQL Script...`
3. Navega hasta la carpeta del proyecto y selecciona:
   ```
   database/observador_virtual.sql
   ```
4. Una vez cargado el script, presiona el botón **"Execute"** (rayo amarillo) o usa el atajo `Ctrl + Shift + Enter`.
5. Verifica en el panel izquierdo (Schemas) que aparezca la base de datos **`observador_virtual`**.

---

### Opción B — Usando phpMyAdmin (XAMPP / WAMP)

1. Abre tu navegador y ve a: `http://localhost/phpmyadmin`
2. Haz clic en **"Importar"** en el menú superior.
3. En la sección "Archivo a importar", haz clic en **"Seleccionar archivo"**.
4. Busca y selecciona: `database/observador_virtual.sql`
5. Haz clic en el botón **"Continuar"** (o "Go") al final de la página.
6. Deberías ver un mensaje de éxito y la base de datos `observador_virtual` aparecerá en el panel izquierdo.

---

### Opción C — Usando la línea de comandos (Terminal / CMD)

1. Abre una terminal (CMD en Windows, Terminal en Mac/Linux).
2. Navega hasta la carpeta del proyecto:
   ```bash
   cd ruta/hacia/observador_virtual/database
   ```
3. Ejecuta el siguiente comando (reemplaza `tu_usuario` por tu usuario de MySQL, generalmente `root`):
   ```bash
   mysql -u tu_usuario -p < observador_virtual.sql
   ```
4. El sistema te pedirá tu contraseña de MySQL. Ingrésala y presiona Enter.
5. Si no aparece ningún error, la base de datos fue creada exitosamente.

   Para verificar:
   ```bash
   mysql -u tu_usuario -p
   ```
   Una vez dentro de MySQL:
   ```sql
   SHOW DATABASES;
   USE observador_virtual;
   SHOW TABLES;
   ```

---

## PARTE 3 — FLUJO DE NAVEGACIÓN

```
login.html
  ├── dashboard.html
  │     ├── lista-estudiantes.html
  │     │     └── observador-detalle.html
  │     │           └── observador-academico.html
  │     └── datos-personales.html
  │           └── info-contacto.html
  └── recuperar-contrasena.html
        └── verificar-codigo.html
              └── nueva-contrasena.html
                    └── exito-contrasena.html
                          └── login.html
```

---

## PARTE 4 — ESTRUCTURA DE LA BASE DE DATOS

| Tabla                    | Descripción                                      |
|--------------------------|--------------------------------------------------|
| `usuarios`               | Usuarios del sistema (admin, docente, acudiente) |
| `recuperacion_contrasena`| Códigos temporales para recuperar contraseña     |
| `grados`                 | Grados y cursos escolares                        |
| `estudiantes`            | Datos completos de cada estudiante               |
| `documentos_estudiante`  | Archivos adjuntos de cada estudiante             |
| `observaciones`          | Registro de observaciones académicas             |

### Vistas incluidas:
- `v_estudiantes` — Lista de estudiantes con grado completo.
- `v_observaciones` — Observaciones con nombre del estudiante y grado.

---

## PARTE 5 — PERSONALIZACIÓN

- **Logo del colegio:** Reemplaza el texto "Logo" o "(logo del colegio)" por una etiqueta `<img>` con la ruta de tu imagen.
- **Nombre del sistema:** Busca "I.J.P. Company" en los archivos HTML y reemplázalo por el nombre de tu institución.
- **Colores:** Los colores principales se encuentran en `css/styles.css`. El azul principal es `#2563eb`.
- **Datos reales:** Para usar datos reales de la base de datos, el proyecto requiere un backend (PHP, Node.js, Python, etc.) que consulte MySQL y sirva los datos a las páginas HTML.

---

## SOPORTE

Para conectar este frontend estático con la base de datos MySQL necesitas un backend.
Tecnologías recomendadas:
- **PHP** con PDO o MySQLi
- **Node.js** con Express + mysql2
- **Python** con Flask + PyMySQL

---

*© 2025 I.J.P. Company - Observador Virtual*
