# NutriApp

A cross-platform (Android + iOS) nutrition app built with **Flutter**, featuring AI-powered food
recognition from photos (**Google Gemini Vision**), a smart pantry that auto-fills from grocery
receipts, weekly reports with AI-generated recommendations, and a **Local-First** architecture:
user data lives encrypted on-device, network access is used only for the AI calls.

The app's UI is entirely in Spanish (its target users). Full functional spec in
[docs/ERS.md](docs/ERS.md).

## Problem it solves

Keeping an accurate nutrition log is tedious: weighing food, looking up every ingredient in a
database, and manually tracking a kitchen pantry. NutriApp uses AI vision models so that a single
photo — of a plate of food, a printed nutrition label, or a grocery receipt — replaces that manual
work, without relying on a custom backend or a preloaded food database.

## Core features

- **Photo-based meal logging**: identifies the dish, its individual components, and estimates
  calories/protein/carbs/fat per portion. When the result's confidence is low, the app explains
  what to do to get a better photo instead of showing unreliable or blank data.
- **Printed nutrition label recognition**, as an alternate mode for packaged products.
- **Smart pantry**: added manually or from a photo/PDF of a grocery receipt, with real text
  extraction (no third-party OCR) and a review screen before saving. Automatically filters out
  non-food items (cleaning supplies, toiletries, etc.).
- **Daily dashboard** of calories and macronutrients against the user's goal.
- **Weekly summary** with charts, most-consumed foods, AI-generated nutrition recommendations
  (with a rule-based fallback if the AI is unavailable), and a **3-day meal planner** that
  prioritizes what's already in the pantry — all exportable to a shareable PDF (WhatsApp, Gmail,
  etc.).
- **Daily reminders** scheduled on-device (no push notification server) and **user data export**
  to JSON.
- Local sign-up/login (email/password), no external auth dependency.

## Notable technical decisions

- **Local-First in practice, not just in name**: the database (SQLite + SQLCipher, AES-256) lives
  encrypted on the device; the key is stored in the platform Keychain (iOS) / Keystore (Android).
  The only network call is to the AI provider, and each user supplies their own key for it from
  Settings — it never lives in source code or in the repository.
- **Prompt engineering for reliability**: the food-recognition prompt forces an explicit
  step-by-step identification process (reference scale → estimated weight → nutrition calculation
  → confidence self-assessment) instead of asking the model directly for a result. When the model
  can't identify something with confidence, the response says so explicitly instead of guessing —
  and tells the user how to take a better photo.
- **Service interfaces, not direct calls**: `FoodRecognitionService`, `InvoiceParsingService`, and
  `AuthRepository` are domain-level interfaces with a swappable concrete implementation (Gemini,
  a specific grocery chain's receipt format, local auth). Switching AI providers, moving the call
  behind a proper backend, or adding an external login provider is a single-class change — see
  [Extending the app](#extending-the-app).
- **Structured AI output** (Gemini `responseSchema`) instead of free-text parsing, so every call's
  result is deterministically validatable JSON.

## Architecture

Clean Architecture with strict layer separation:

```
lib/
├── domain/         # Pure entities and business rules — no Flutter or network dependencies
│   ├── entities/
│   ├── repositories/   # Interfaces (contracts), no implementation
│   └── usecases/
├── data/           # Concrete implementations of the domain contracts
│   ├── local/          # SQLCipher schema
│   ├── repositories/
│   └── services/        # Gemini Vision, receipt parsing, data export, PDF generation
├── presentation/   # UI and state (Riverpod), organized by feature
│   ├── auth/ dashboard/ food_log/ pantry/ profile/ reports/ settings/ onboarding/
├── core/           # Theming, security, notifications, localization, error types
└── l10n/           # Spanish UI strings (ARB), generated via flutter gen-l10n
```

**Stack**: Flutter/Dart · Riverpod (state) · `go_router` (navigation) · SQLite + SQLCipher
(encrypted persistence) · `flutter_secure_storage` (Keychain/Keystore) · Gemini Vision API ·
`flutter_local_notifications` · Syncfusion PDF · `fl_chart`.

~9,000 lines of Dart in `lib/`, 8 test suites / 54 unit and widget tests.

## Screenshots

*(add 2-3 screenshots here — dashboard, photo-based meal logging, weekly summary — recommended
before sharing this repository publicly)*

## Running the project

Requirements: Flutter 3.44+, Xcode with the iOS simulator, Android SDK with `ANDROID_HOME`
configured and an AVD created.

```bash
flutter pub get
flutter gen-l10n     # regenerate strings after editing lib/l10n/app_es.arb
flutter run          # picks the active simulator/emulator, or use -d <device-id>
```

Verification:

```bash
flutter analyze
flutter test
```

### Enabling photo recognition (1 minute)

Photo-based recognition requires a free personal Google Gemini API key:

1. Go to **aistudio.google.com/app/apikey**, sign in with a Google account, and create a key
   (free within the free tier).
2. Open NutriApp → **Settings** → **AI API Key (Gemini)** → paste the key.
   It's stored encrypted on-device only.
3. Done — "Log meal" → "Take photo" now identifies the food and calculates its nutrition info.

## Extending the app

**Switch AI providers, or move the call behind a proper backend**
(recommended before a store release, so no key ships in the mobile client):
implement `FoodRecognitionService`
([lib/data/services/food_recognition_service.dart](lib/data/services/food_recognition_service.dart))
and update `foodRecognitionServiceProvider` in
[lib/presentation/food_log/providers/food_log_providers.dart](lib/presentation/food_log/providers/food_log_providers.dart).

**Support receipts from another store, or real OCR** (photos instead of a text-based PDF):
implement `InvoiceParsingService`
([lib/data/services/invoice_parsing_service.dart](lib/data/services/invoice_parsing_service.dart))
and update `invoiceParsingServiceProvider` in
[lib/presentation/pantry/providers/pantry_providers.dart](lib/presentation/pantry/providers/pantry_providers.dart).
`CsuInvoiceParsingService` currently only recognizes one grocery chain's electronic receipt format.

**Add Google/Microsoft login**: implement `AuthRepository`
([lib/domain/repositories/auth_repository.dart](lib/domain/repositories/auth_repository.dart))
against Firebase/Supabase or another provider, and update `authRepositoryProvider` in
[lib/presentation/auth/providers/auth_providers.dart](lib/presentation/auth/providers/auth_providers.dart).

## Scope and known limitations

Out of scope by product decision, not a technical limitation: barcode scanning, a conversational
nutrition assistant. Documented but not yet implemented (see `docs/ERS.md`, section 9): OCR for
photographed receipts or other store formats, a backend proxy for multi-user scale, Google/
Microsoft login.
