# NutriApp

Aplicación móvil de nutrición inteligente (Android + iOS) construida en **Flutter**, con
reconocimiento de alimentos por foto vía **IA generativa (Google Gemini Vision)**, despensa
inteligente con extracción automática de facturas, reportes semanales con recomendaciones
generadas por IA, y arquitectura **Local-First**: los datos del usuario viven cifrados en el
dispositivo, la red se usa únicamente para las llamadas a los modelos de IA.

Interfaz completamente en español. Especificación funcional completa en [docs/ERS.md](docs/ERS.md).

## Qué resuelve

Llevar un registro nutricional preciso es tedioso: pesar comida, buscar cada ingrediente en una
base de datos, y llevar cuenta manual de la despensa. NutriApp usa modelos de visión de IA para
que una sola foto —de un plato de comida, de una etiqueta nutricional, o de una factura del
supermercado— reemplace ese trabajo manual, sin depender de un backend propio ni de bases de datos
de alimentos precargadas.

## Funcionalidad principal

- **Registro de comidas por foto**: identifica el platillo, sus componentes individuales y estima
  calorías/proteína/carbohidratos/grasas por porción. Cuando la confianza del resultado es baja,
  la app explica qué hacer para mejorar la foto en vez de mostrar datos poco confiables o vacíos.
- **Reconocimiento de etiquetas nutricionales impresas**, como modo alterno para productos
  empacados.
- **Despensa inteligente**: alta manual o mediante foto/PDF de una factura de supermercado, con
  extracción de texto real (sin OCR de terceros) y una pantalla de revisión antes de guardar.
  Filtra automáticamente productos no comestibles (limpieza, higiene, etc.).
- **Dashboard diario** de calorías y macronutrientes frente a la meta del usuario.
- **Resumen semanal** con gráficos, alimentos más consumidos, recomendaciones nutricionales
  generadas por IA (con una alternativa basada en reglas si la IA no responde), y un
  **planificador de comidas de 3 días** que prioriza lo que ya hay en la despensa — todo
  exportable a PDF y compartible por WhatsApp/Gmail.
- **Recordatorios diarios** programados en el sistema operativo (sin servidor de notificaciones
  push) y **exportación de datos del usuario** a JSON.
- Registro/inicio de sesión local (correo/contraseña), sin dependencias externas.

## Decisiones técnicas destacables

- **Local-First real, no solo de nombre**: la base de datos (SQLite + SQLCipher, AES-256) vive
  cifrada en el dispositivo; la clave se guarda en Keychain (iOS) / Keystore (Android). La única
  llamada de red es hacia el proveedor de IA, y la clave de ese proveedor la aporta cada usuario
  desde Configuración — nunca vive en el código fuente ni en el repositorio.
- **Ingeniería de prompts orientada a confiabilidad**: el prompt de reconocimiento de alimentos
  fuerza un proceso de identificación explícito en pasos (escala de referencia → peso estimado →
  cálculo nutricional → autoevaluación de confianza), en vez de pedirle directamente un resultado
  al modelo. Cuando el modelo no puede identificar algo con certeza, la respuesta lo declara en vez
  de inventar un valor — y le indica al usuario cómo tomar una mejor foto.
- **Interfaces de servicio, no llamadas directas**: `FoodRecognitionService`,
  `InvoiceParsingService` y `AuthRepository` son interfaces de dominio con una implementación real
  intercambiable (Gemini, CSU/Automercado, auth local). Cambiar de proveedor de IA, mover la
  llamada detrás de un backend propio, o agregar un proveedor de login externo es un cambio de una
  sola clase — ver [Extender la aplicación](#extender-la-aplicación).
- **Salidas estructuradas de IA** (`responseSchema` de Gemini) en vez de parseo de texto libre,
  para que el resultado de cada llamada sea JSON validable de forma determinista.

## Arquitectura

Clean Architecture con separación estricta de capas:

```
lib/
├── domain/         # Entidades y reglas de negocio puras — sin dependencias de Flutter ni de red
│   ├── entities/
│   ├── repositories/   # Interfaces (contratos), sin implementación
│   └── usecases/
├── data/           # Implementaciones concretas de los contratos del dominio
│   ├── local/          # Esquema SQLCipher
│   ├── repositories/
│   └── services/        # Gemini Vision, parseo de facturas, exportación, generación de PDF
├── presentation/   # UI y estado (Riverpod), organizada por feature
│   ├── auth/ dashboard/ food_log/ pantry/ profile/ reports/ settings/ onboarding/
├── core/           # Theming, seguridad, notificaciones, localización, errores
└── l10n/           # Strings en español (ARB), generadas por flutter gen-l10n
```

**Stack**: Flutter/Dart · Riverpod (estado) · `go_router` (navegación) · SQLite + SQLCipher
(persistencia cifrada) · `flutter_secure_storage` (Keychain/Keystore) · Gemini Vision API ·
`flutter_local_notifications` · Syncfusion PDF · `fl_chart`.

~9.000 líneas de Dart en `lib/`, 8 suites de test / 54 tests unitarios y de widgets.

## Capturas

*(agregar aquí 2-3 capturas de pantalla del dashboard, el registro de comida por foto, y el
resumen semanal — recomendado antes de compartir el repositorio públicamente)*

## Ejecutar el proyecto

Requisitos: Flutter 3.44+, Xcode con simulador iOS, Android SDK con `ANDROID_HOME` configurado y
un AVD creado.

```bash
flutter pub get
flutter gen-l10n     # regenerar strings si se edita lib/l10n/app_es.arb
flutter run          # elige el simulador/emulador activo, o usa -d <device-id>
```

Verificación:

```bash
flutter analyze
flutter test
```

### Activar el reconocimiento de fotos (1 minuto)

El reconocimiento por foto requiere una clave de API gratuita propia de Google Gemini:

1. Ir a **aistudio.google.com/app/apikey**, iniciar sesión con una cuenta de Google y crear una
   clave (gratuita dentro del nivel gratuito).
2. Abrir NutriApp → **Configuración** → **Clave de API de IA (Gemini)** → pegar la clave.
   Se guarda cifrada únicamente en el dispositivo.
3. Listo — "Registrar comida" → "Tomar foto" ya identifica el alimento y calcula la información
   nutricional.

## Extender la aplicación

**Cambiar de proveedor de IA o mover la llamada detrás de un backend propio**
(recomendado antes de publicar en tiendas, para que ninguna clave viva en el cliente móvil):
implementar `FoodRecognitionService`
([lib/data/services/food_recognition_service.dart](lib/data/services/food_recognition_service.dart))
y actualizar `foodRecognitionServiceProvider` en
[lib/presentation/food_log/providers/food_log_providers.dart](lib/presentation/food_log/providers/food_log_providers.dart).

**Soportar facturas de otro supermercado o con OCR real** (fotos en vez de PDF con texto):
implementar `InvoiceParsingService`
([lib/data/services/invoice_parsing_service.dart](lib/data/services/invoice_parsing_service.dart))
y actualizar `invoiceParsingServiceProvider` en
[lib/presentation/pantry/providers/pantry_providers.dart](lib/presentation/pantry/providers/pantry_providers.dart).
`CsuInvoiceParsingService` hoy solo reconoce el formato de Supermercados Unidos/CSU/Automercado.

**Agregar login con Google/Microsoft**: implementar `AuthRepository`
([lib/domain/repositories/auth_repository.dart](lib/domain/repositories/auth_repository.dart))
contra Firebase/Supabase u otro proveedor, y actualizar `authRepositoryProvider` en
[lib/presentation/auth/providers/auth_providers.dart](lib/presentation/auth/providers/auth_providers.dart).

## Alcance y limitaciones conocidas

Fuera de alcance por decisión de producto, no por limitación técnica: escáner de código de
barras, asistente conversacional de nutrición. Documentado pero no implementado (ver
`docs/ERS.md`, sección 9): OCR de facturas fotografiadas de otros formatos, proxy backend para
uso multiusuario a escala, inicio de sesión con Google/Microsoft.
