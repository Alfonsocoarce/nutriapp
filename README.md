# NutriApp

Aplicación móvil de nutrición inteligente con IA — Android e iOS, arquitectura **Local First**.
Ver la especificación completa en [docs/ERS.md](docs/ERS.md).

## Estado actual (Fase 1 — MVP)

Implementado y funcional en simulador iOS / emulador Android:

- Registro e inicio de sesión locales (correo/contraseña, sin conexión) — RF-01 parcial
- Perfil de usuario y objetivos nutricionales — RF-02, RF-03
- Captura de foto (cámara/galería) con reconocimiento de alimentos **simulado**
  (`MockFoodRecognitionService`) y registro manual — RF-04, RF-05 (mock), RF-06, RF-07, RF-08
- Despensa con categorías, cantidades y vencimientos, agregada manualmente o vía **factura en PDF**
  con extracción **real** de texto (`CsuInvoiceParsingService`, formato "Tiquete Electrónico" de
  Supermercados Unidos/CSU/Automercado) y pantalla de revisión antes de guardar — RF-09, RF-10, RF-11
- Panel principal con calorías/macros del día — RF-17
- Interfaz completamente en español
- Base de datos local cifrada con SQLCipher (AES-256), clave en Keychain/Keystore — Sección 4

Pendiente (documentado en `docs/ERS.md` Sección 9, no implementado aún): reconocimiento de IA
real y OCR real (ambos detrás de servicios ya preparados para recibir la implementación real),
planificador con IA, asistente conversacional, código de barras, reportes semanales/exportación,
notificaciones, inicio de sesión con Google/Microsoft.

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

## Activar reconocimiento de IA real

1. Desplegar un backend/proxy sin estado (Cloud Functions, Edge Functions, o similar) que reenvíe
   la foto al proveedor de visión (OpenAI Vision / Google Gemini Vision) — la clave de API nunca
   debe vivir en la app móvil.
2. Crear una nueva clase que implemente `FoodRecognitionService`
   ([lib/data/services/food_recognition_service.dart](lib/data/services/food_recognition_service.dart))
   que llame a ese backend.
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
