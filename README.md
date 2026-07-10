# NutriApp

Aplicación móvil de nutrición inteligente con IA — Android e iOS, arquitectura **Local First**.
Ver la especificación completa en [docs/ERS.md](docs/ERS.md).

## Estado actual (Fase 1 — MVP)

Implementado y funcional en simulador iOS / emulador Android:

- Registro e inicio de sesión locales (correo/contraseña, sin conexión) — RF-01 parcial
- Perfil de usuario y objetivos nutricionales — RF-02, RF-03
- Captura de foto (cámara/galería) con reconocimiento de alimentos **real** vía **Gemini Vision**
  (`GeminiFoodRecognitionService`, modelo `gemini-flash-lite-latest`) y registro manual — RF-04,
  RF-05, RF-06, RF-07, RF-08. Verificado end-to-end con una foto real: identifica correctamente el
  alimento, ingredientes y valores nutricionales. **Requiere que cada usuario configure su propia
  clave de API gratuita en Configuración** (ver abajo) — sin clave, la app muestra un mensaje claro
  con acceso directo a Configuración en vez de fallar en silencio; si la API responde con error
  temporal (503, alta demanda), el diálogo de error incluye un botón "Reintentar" funcional.
- Despensa con categorías, cantidades y vencimientos, agregada manualmente o vía **factura en PDF**
  con extracción **real** de texto (`CsuInvoiceParsingService`, formato "Tiquete Electrónico" de
  Supermercados Unidos/CSU/Automercado) y pantalla de revisión antes de guardar — RF-09, RF-10, RF-11
- Panel principal con calorías/macros del día — RF-17
- Interfaz completamente en español
- Base de datos local cifrada con SQLCipher (AES-256), clave en Keychain/Keystore — Sección 4

Pendiente (documentado en `docs/ERS.md` Sección 9, no implementado aún): OCR de facturas
fotografiadas u otros formatos de supermercado, proxy backend opcional para uso multiusuario,
planificador con IA, asistente conversacional, código de barras, reportes semanales/exportación,
notificaciones, inicio de sesión con Google/Microsoft.

## Activar el reconocimiento de fotos (obligatorio, 1 minuto)

El reconocimiento de alimentos por foto no funciona hasta que agregues tu propia clave de API,
gratuita, de Google Gemini:

1. Ve a **aistudio.google.com/app/apikey**, inicia sesión con una cuenta de Google y crea una clave
   (botón "Create API key"). Es gratuita dentro de los límites del nivel gratuito.
2. Abre NutriApp → pestaña **Configuración** → **Clave de API de IA (Gemini)**.
3. Pega la clave y presiona **Guardar clave**. Se guarda cifrada únicamente en este dispositivo
   (Keychain en iOS, Keystore en Android) — nunca se escribe en el código fuente ni se sube a git.
4. Listo — "Registrar comida" → "Tomar foto" ahora identifica el alimento, estima porciones y
   calcula la información nutricional automáticamente.

## Requisitos

- Flutter 3.44+ (`brew install --cask flutter`)
- Xcode (iOS) con el simulador instalado
- Android SDK con `ANDROID_HOME` configurado y al menos un AVD creado

## Ejecutar

```bash
flutter pub get
flutter gen-l10n     # regenerar strings si se edita lib/l10n/app_es.arb
flutter run          # elige el simulador/emulador activo, o usa -d <device-id>
```

## Verificación

```bash
flutter analyze
flutter test
```

## Usar un proveedor de IA distinto, o un proxy backend

`GeminiFoodRecognitionService`
([lib/data/services/gemini_food_recognition_service.dart](lib/data/services/gemini_food_recognition_service.dart))
llama directamente a la API de Gemini con la clave del usuario (ver sección anterior). Para una
app publicada en tiendas con muchos usuarios, la opción más segura es mover esa llamada detrás de
un backend propio sin estado (Cloud Functions, Edge Functions, etc.) que reenvíe la foto al
proveedor de visión, de forma que ninguna clave viva en la app móvil:

1. Desplegar el backend/proxy.
2. Crear una nueva clase que implemente `FoodRecognitionService`
   ([lib/data/services/food_recognition_service.dart](lib/data/services/food_recognition_service.dart))
   que llame a ese backend en vez de a Gemini directamente.
3. Cambiar la implementación devuelta por `foodRecognitionServiceProvider` en
   [lib/presentation/food_log/providers/food_log_providers.dart](lib/presentation/food_log/providers/food_log_providers.dart).

## Facturas de otros supermercados / con OCR real

`CsuInvoiceParsingService` ([lib/data/services/csu_invoice_parsing_service.dart](lib/data/services/csu_invoice_parsing_service.dart))
solo reconoce el formato de factura electrónica de Supermercados Unidos (CSU/Automercado), ya que
parsea el texto real embebido en ese PDF. Para otro supermercado o para facturas fotografiadas
(sin capa de texto):

1. Si el nuevo formato también es un PDF con texto, ajustar/duplicar el patrón de expresión
   regular en `CsuInvoiceParsingService`.
2. Si requiere OCR o visión por IA (foto de una factura impresa), esa lógica debe correr detrás de
   un backend propio — nunca con una clave de API embebida en la app.
3. Crear una nueva clase que implemente `InvoiceParsingService`
   ([lib/data/services/invoice_parsing_service.dart](lib/data/services/invoice_parsing_service.dart))
   y cambiar la implementación devuelta por `invoiceParsingServiceProvider` en
   [lib/presentation/pantry/providers/pantry_providers.dart](lib/presentation/pantry/providers/pantry_providers.dart).

## Activar inicio de sesión con Google/Microsoft

1. Crear un proyecto Firebase o Supabase y habilitar los proveedores Google y Microsoft.
2. Implementar una nueva clase que cumpla `AuthRepository`
   ([lib/domain/repositories/auth_repository.dart](lib/domain/repositories/auth_repository.dart)).
3. Cambiar la implementación devuelta por `authRepositoryProvider` en
   [lib/presentation/auth/providers/auth_providers.dart](lib/presentation/auth/providers/auth_providers.dart).

## Arquitectura

Clean Architecture (`lib/domain` → entidades y reglas de negocio puras; `lib/data` → repositorios
e infraestructura; `lib/presentation` → pantallas y providers Riverpod), con SQLite+SQLCipher como
base de datos local cifrada y `go_router` para navegación.
