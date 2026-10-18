
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

initializeApp();

const resendApiKey = defineSecret("RESEND_API_KEY");

function escaparHTML(valor = "") {
    return String(valor).replace(/[&<>"']/g, (caracter) => {
        const entidades = {
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            '"': "&quot;",
            "'": "&#39;"
        };

        return entidades[caracter];
    });
}

function crearPlantilla(nombre, enlace) {
    const nombreSeguro = escaparHTML(nombre || "usuario");
    const enlaceSeguro = escaparHTML(enlace);

    return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verifica tu correo | Observador Virtual</title>
</head>
<body style="margin:0;padding:0;background-color:#f1f3f5;font-family:Arial,Helvetica,sans-serif;color:#1f2937;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0"
    style="width:100%;background-color:#f1f3f5;">
    <tr>
      <td align="center" style="padding:35px 12px;">
        <table role="presentation" width="600" cellspacing="0" cellpadding="0"
          style="width:100%;max-width:600px;background:#ffffff;border-radius:12px;overflow:hidden;">

          <tr>
            <td style="background:#111111;padding:25px 24px;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="100" valign="middle" style="width:100px;padding-right:18px;">
                    <img
                      src="https://raw.githubusercontent.com/joeldiscord345-debug/I.J.P-Company-Observador-virtual-/main/logo%20circular%20IJP%20COMPANY-.png"
                      alt="Logo de I.J.P. Company"
                      width="88"
                      style="display:block;width:88px;height:auto;border:0;"
                    >
                  </td>
                  <td valign="middle">
                    <div style="color:#ffffff;font-size:27px;line-height:1.2;font-weight:700;">
                      Observador Virtual
                    </div>
                    <div style="margin-top:7px;color:#d1d5db;font-size:14px;line-height:1.5;">
                      I.J.P. Company
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <tr>
            <td style="padding:36px 30px 30px;">
              <h1 style="margin:0 0 20px;color:#111827;font-size:25px;line-height:1.35;">
                ¡Hola, ${nombreSeguro}!
              </h1>

              <p style="margin:0 0 16px;color:#374151;font-size:16px;line-height:1.8;">
                ¡Gracias por registrarte en <strong>Observador Virtual</strong>!
              </p>

              <p style="margin:0 0 28px;color:#374151;font-size:16px;line-height:1.8;">
                Para completar tu registro, necesitamos verificar tu dirección
                de correo electrónico. Pulsa el siguiente botón para confirmar
                tu correo y continuar con el proceso.
              </p>

              <table role="presentation" cellspacing="0" cellpadding="0"
                align="center" style="margin:0 auto 28px;">
                <tr>
                  <td align="center" bgcolor="#2563eb" style="background:#2563eb;border-radius:8px;">
                    <a href="${enlaceSeguro}" target="_blank"
                      style="display:inline-block;padding:16px 24px;color:#ffffff;font-size:15px;line-height:1.4;font-weight:700;text-align:center;text-decoration:none;border-radius:8px;">
                      Verificar mi correo electrónico
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 16px;color:#6b7280;font-size:13px;line-height:1.8;">
                Si el botón no funciona, copia el enlace de verificación y
                pégalo directamente en la barra de direcciones de tu navegador.
              </p>

              <p style="margin:0;color:#6b7280;font-size:13px;line-height:1.8;">
                Si no creaste esta cuenta, puedes ignorar este mensaje.
              </p>
            </td>
          </tr>

          <tr>
            <td style="padding:22px 24px;background:#f9fafb;border-top:1px solid #e5e7eb;text-align:center;">
              <p style="margin:0;color:#4b5563;font-size:13px;line-height:1.6;">
                <strong>Observador Virtual</strong> · I.J.P. Company
              </p>
              <p style="margin:8px 0 0;color:#9ca3af;font-size:12px;line-height:1.6;">
                Mensaje automático de verificación de correo electrónico.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

exports.enviarCorreoVerificacionPersonalizado = onCall(
    { secrets: [resendApiKey] },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "Debes iniciar el proceso de registro para solicitar la verificación."
            );
        }

        try {
            const usuario = await getAuth().getUser(request.auth.uid);

            if (!usuario.email) {
                throw new HttpsError(
                    "failed-precondition",
                    "La cuenta no tiene una dirección de correo."
                );
            }

            if (usuario.emailVerified) {
                return { success: true, alreadyVerified: true };
            }

            const enlace = await getAuth().generateEmailVerificationLink(
                usuario.email
            );

            const html = crearPlantilla(usuario.displayName, enlace);

            const respuesta = await fetch("https://api.resend.com/emails", {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${resendApiKey.value()}`,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    from: "Observador Virtual <onboarding@resend.dev>",
                    to: [usuario.email],
                    subject: "Verifica tu correo electrónico | Observador Virtual",
                    html,
                    text:
                        `Hola, ${usuario.displayName || "usuario"}.\n\n` +
                        "Gracias por registrarte en Observador Virtual.\n" +
                        "Verifica tu correo electrónico usando este enlace:\n" +
                        enlace +
                        "\n\nSi no creaste esta cuenta, ignora este mensaje."
                })
            });

            if (!respuesta.ok) {
                const detalle = await respuesta.text();

                console.error(
                    "El proveedor de correo rechazó el envío:",
                    respuesta.status,
                    detalle
                );

                throw new HttpsError(
                    "internal",
                    "No se pudo enviar el correo. Comprueba la configuración del servicio de correo."
                );
            }

            return { success: true };

        } catch (error) {
            if (error instanceof HttpsError) {
                throw error;
            }

            console.error("Error al enviar la verificación:", error);

            throw new HttpsError(
                "internal",
                "No se pudo generar o enviar el correo de verificación."
            );
        }
    }
);
