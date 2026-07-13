# Software Requirements Specification (SRS)

## NutriApp — AI-Powered Smart Nutrition & Meal Planning Mobile App

### Platform
- Android
- iOS

### Language
The entire interface, copy, notifications, error messages, and app configuration are in
**Spanish** (the target user base).

---

## 1. General Objective

Develop a mobile app for Android and iOS that uses Artificial Intelligence to help users improve
their diet by analyzing photos of food, automatically calculating calories and nutrients, managing
a household pantry, and generating personalized, evidence-based meal plans.

The app follows a **Local-First** approach: all user data is stored on-device, and the internet is
used only when required for AI features or optional backup.

## 2. Functional Requirements

### FR-01 Registration and Login

- Sign up via email.
- Sign in with Google.
- Sign in with Microsoft (Outlook, Hotmail, Live, or Office 365).
- Password recovery.
- Persistent session.
- Log out.

> **Implementation note (MVP phase):** Google/Microsoft login requires external provider accounts
> (Firebase/Supabase) that aren't set up yet. The first version implements only local email/
> password registration and login (encrypted on-device, offline). Google/Microsoft access is
> documented as a later phase behind a swappable `AuthService` interface.

### FR-02 User Profile

Name, date of birth, sex, height, current weight, target weight, activity level, nutrition goal,
dietary restrictions, allergies, medical conditions (optional).

### FR-03 Nutrition Goals

Lose weight, gain muscle mass, maintain weight, lower cholesterol, manage diabetes, regulate blood
sugar, eat healthier, reduce body fat, improve athletic performance.

### FR-04 Photo Capture

Take photos with the camera, pick from the gallery, analyze several consecutive photos.

### FR-05 Automatic Food Identification

The AI identifies: food name, ingredients, cooking method, approximate weight, estimated quantity,
number of servings, and the **confidence level** of the identification.

> **Data integrity principle:** when the AI can't determine a value with sufficient confidence,
> the app must show it explicitly as "not available" instead of assuming a value (e.g., not
> filling in missing micronutrients with zero). Showing a blank is preferable to showing an
> incorrect value.
>
> **Implementation note:** implemented for **real** (not mocked) with **Google Gemini Vision**
> (`GeminiFoodRecognitionService`). The user enters their own free API key (obtained at
> aistudio.google.com/app/apikey) in Settings; it's stored encrypted on-device only
> (`ApiKeyStore`) and is never included in source code or the compiled binary. The app calls the
> Gemini API directly over HTTPS with that key, using structured output (JSON Schema) to get the
> food name, ingredients, cooking method, estimated weight, servings, confidence level, and the
> FR-06 nutrition values in a single call. Fields the model can't determine are returned as
> `null`, honoring the data integrity principle above. The model used is the `gemini-flash-lite-
> latest` alias (not a pinned version like `gemini-2.5-flash`): "latest" aliases keep pointing at
> the current model as Google retires older free-tier versions, and the "lite" variant showed more
> free-quota headroom than the full `gemini-flash-latest` alias during testing. Verified with a
> real photo of a plate of food: it correctly identified the dish and its components with high
> confidence.
>
> **Security note:** for a store-published app with many users, the Section 3 recommendation (a
> stateless backend proxy) is still the right call — it avoids exposing any shared key. Since each
> user here supplies their own personal key (with their own free quota), the risk of extracting it
> from the device is limited to that individual's account, not shared infrastructure — an
> acceptable tradeoff for personal/local-first use while there's no project-owned cloud account.

### FR-06 Nutrition Information

Calories, protein, carbohydrates, fat, saturated fat, trans fat, fiber, sugars, sodium,
cholesterol, key vitamins, key minerals. Shown via visual cards, a nutrition table, and simple
charts. Follows the same data integrity principle as FR-05.

### FR-07 Automatic Logging

Each photo is stored along with date, time, image, meal type, and nutrition information.

### FR-08 Automatic Classification

Breakfast, morning snack, lunch, afternoon snack, dinner, drink, dessert. The user can edit the
classification.

### FR-09 Receipt Scanning

Upload printed, electronic, or photographed receipts. The AI extracts product, quantity, unit,
date, and price (optional).

> **Implementation note (MVP phase):** implemented for **real** (not mocked) for electronic
> receipts in **PDF** format with a text layer — specifically the "Tiquete Electrónico" format
> used by Corporación Supermercados Unidos (CSU/Automercado, a Costa Rican grocery chain).
> `CsuInvoiceParsingService` extracts the PDF's text with `syncfusion_flutter_pdf` (pure Dart, no
> native code or external services) and parses each product line (code, quantity, description,
> price) via regular expression, assigning a pantry category through a keyword dictionary
> (`InvoiceCategoryGuesser`). The user reviews and corrects each product before saving — the same
> "don't guess" principle as FR-05. Other receipt formats (photographed receipts, other stores)
> require a new `InvoiceParsingService` implementation (possibly OCR/AI behind a proxy),
> swappable at the same extension point.

### FR-10 Manual Purchase Logging

Product, quantity, unit, purchase date, expiration date — via receipt or manual entry.

### FR-11 Smart Pantry

Categories: fruits, vegetables, meats, fish, seafood, dairy, cereals, legumes, snacks, beverages,
frozen foods, condiments. Each product shows available quantity, purchase date, expiration date,
and days remaining.

### FR-12 Smart Planner

Generates a daily and weekly plan using goals, pantry contents, restrictions, preferences, history,
and remaining calories.

> **Additions (based on comparable-app research):**
> - **Recursive/composable recipes**: a recipe can be composed of other recipes (e.g., a cake =
>   dough recipe + filling recipe), rolling up nutrition information recursively.
> - **Duplicate day**: the user can copy an entire day's meals to another date (past or future),
>   speeding up repetitive weekly planning.

### FR-13 Portion Recommendations

Protein, carbohydrates, vegetables, and healthy fats, adjusted for age, sex, weight, height,
activity level, and goal.

### FR-14 Smart Recommendations

Eat more protein, reduce sugar, reduce sodium, increase fiber, eat more vegetables, reduce
saturated fat, use ingredients that are about to expire.

### FR-15 Nutrition Assistant

Natural-language queries (what can I cook?, what can I have for breakfast/dinner?, can I eat this?,
which food has more protein?, how do I reach my goal?) using inventory, history, goals, and
available calories.

### FR-16 Barcode Scanner

Nutrition information, ingredients, allergens, and serving size.

### FR-17 Main Dashboard

Calories consumed/remaining, protein, carbs, fat, water, daily goal, progress, current weight.

### FR-18 Weekly Summary

Automatic report from Monday 12:00 a.m. to Sunday 5:00 p.m.: totals for calories, protein, carbs,
fat, fiber, sugar, sodium, cholesterol, number of meals, category breakdown, and goal adherence.

### FR-19 Statistics

Daily, weekly, monthly consumption; weight trend; macronutrients; goal adherence.

### FR-20 Export

PDF, Excel, CSV.

> **Implementation note:** the weekly report exports to **PDF** (`WeeklyReportPdfService`,
> shareable via WhatsApp/Gmail/etc.). A full raw data export (profile, meal history, pantry) to
> **JSON** is also implemented (`DataExportService`, Settings → "Export data"). Excel/CSV export
> is not implemented.

### FR-21 Notifications

Log meals, drink water, eat, buy groceries, use ingredients about to expire, check the weekly
summary.

> **Implementation note:** implemented as a single configurable **daily reminder** (time chosen by
> the user in Settings), scheduled on-device via `flutter_local_notifications` — no push
> notification server involved. The more granular per-event notifications listed above (water,
> expiring ingredients, etc.) are not implemented.

### FR-22 History

Photos, plans, reports, weight, goals, statistics.

### FR-23 Settings

Edit profile, change goal, change language, enable/disable notifications, export data, delete all
data, log out.

> **Implementation note:** the app ships Spanish-only by product decision, so the change-language
> option was dropped rather than implemented. Notifications and data export are implemented (see
> FR-21, FR-20); profile editing and API key management are also implemented. "Delete all data"
> is not implemented as a standalone action.

## 3. AI Requirements

- Identify food from photos.
- Estimate portions.
- Calculate calories and macronutrients; micronutrients when possible.
- Recommend portions and generate meal plans.
- Analyze eating habits; detect excess sugar, sodium, and fat; detect nutritional deficiencies.
- Recommend dietary improvements and adapt as it learns the user's habits.

> **Security requirement (new):** calls to AI vision models must go through a **thin, stateless
> backend/proxy**. The AI API key (OpenAI/Gemini Vision) must **never** ship in the mobile app
> binary — it's trivially extractable. The proxy only forwards the photo → result request,
> without storing user data, preserving the Local-First approach for everything else.
>
> **Recommended optimization:** cache results for repeated meals (by image hash or embedding)
> before invoking the vision model again, reducing cost and latency.

## 4. Storage Requirements — Local-First Architecture

All user data (profile, photos, analysis results, history, pantry, receipts, reports, settings,
statistics, goals) is stored locally, encrypted, and the app works fully offline for viewing
already-stored data.

Internet access is required only for: processing new photos via AI, updating nutrition databases,
optional backups, and app updates.

The user can delete all their data at any time.

## 5. Non-Functional Requirements

- Compatible with Android 12+ and iOS 16+.
- Modern, intuitive, easy-to-use interface, entirely in Spanish.
- Photo analysis in under five seconds (target).
- Modular, scalable architecture.
- Data encryption.
- WCAG 2.2 AA accessibility.
- Efficient battery and storage usage.
- Smooth experience even with thousands of records.

## 6. Nutrition Standards

Based on WHO, Dietary Reference Intakes (DRI), USDA MyPlate, American Heart Association, American
Diabetes Association, Academy of Nutrition and Dietetics, and the user's country's official dietary
guidelines when available.

Recommendations are informational/educational only and don't replace care from a doctor or
registered dietitian.

## 7. Technologies

- **Frontend:** Flutter (single codebase for Android and iOS).
- **State management:** Riverpod.
- **Local database:** Isar, encrypted.
- **Authentication:** local (email/password) in the initial phase; Firebase Authentication or
  Supabase Auth (Google, Microsoft) in later phases.
- **Food recognition AI:** OpenAI Vision or Google Gemini Vision, behind a proper backend proxy
  (see Section 3).
- **Receipt OCR:** Google ML Kit or Tesseract OCR.
- **Nutrition databases:** USDA FoodData Central, Open Food Facts, and the **Swiss Food
  Composition Database** (an additional source to improve micronutrient coverage).
- **Notifications:** Firebase Cloud Messaging and local notifications.
- **Charts:** FL Chart.
- **Architecture:** Clean Architecture (data/domain/presentation).
- **Distribution:** build/release automation with Fastlane for both stores.

## 8. Differentiating Features

Automatic food recognition from photos, AI-based portion estimation, automatic calorie/nutrient
calculation, smart pantry management (receipt or manual), automatic meal planning (including
recursive recipes and day duplication), evidence-based recommendations, tracking via
dashboards/charts/reports, a Local-First approach that prioritizes privacy, Android/iOS
compatibility from a single codebase, and a design built to grow (smartwatches, recipes,
restaurant menus, advanced conversational assistants).

## 9. Build Phases

**Phase 1 — MVP (current):** FR-01 (local email/password only), FR-02, FR-03, FR-04/05/06/07/08
(**real** photo recognition with Gemini Vision, requires the user to set up their own free API key
in Settings), FR-09 (PDF receipt scanning with **real** extraction for the CSU/Automercado format),
FR-11 (pantry, manual or via receipt), FR-17 (main dashboard), FR-18/19 (weekly summary with
charts and AI recommendations), FR-20 (PDF report export + full JSON data export), FR-21 (daily
reminder notification), FR-12/13/14 partial (3-day AI meal planner inside the weekly PDF, scoped to
pantry contents and recent habits). Runs on the iOS simulator and Android emulator.

**Later phases (documented, not yet implemented):** FR-09 with other receipt formats or photo OCR,
an optional backend proxy to hide the Gemini key in a multi-user deployment, FR-15 (conversational
assistant), FR-16 (barcode scanning — explicitly out of scope by product decision), Excel/CSV
export, per-event notifications beyond the daily reminder, Google/Microsoft login.

---

*This document incorporates findings from a comparative study of similar open-source apps
(OpenNutriTracker, Caloriemate, PANTS, FoodYou, Mega-Fitness-App) conducted before development
began.*
