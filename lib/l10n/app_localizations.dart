import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'NutriApp'**
  String get appTitle;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a NutriApp'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu nutrición, con inteligencia artificial'**
  String get authWelcomeSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get authRegisterButton;

  /// No description provided for @authRegisterLink.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get authRegisterLink;

  /// No description provided for @authLoginLink.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get authLoginLink;

  /// No description provided for @authLogoutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get authLogoutButton;

  /// No description provided for @authInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico no válido'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get authPasswordTooShort;

  /// No description provided for @authPasswordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsDontMatch;

  /// No description provided for @authEmailAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este correo'**
  String get authEmailAlreadyExists;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get authInvalidCredentials;

  /// No description provided for @authGoogleComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión con Google próximamente'**
  String get authGoogleComingSoon;

  /// No description provided for @authMicrosoftComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión con Microsoft próximamente'**
  String get authMicrosoftComingSoon;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileName;

  /// No description provided for @profileBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get profileBirthDate;

  /// No description provided for @profileSex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get profileSex;

  /// No description provided for @profileSexMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get profileSexMale;

  /// No description provided for @profileSexFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get profileSexFemale;

  /// No description provided for @profileSexOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get profileSexOther;

  /// No description provided for @profileHeight.
  ///
  /// In es, this message translates to:
  /// **'Estatura (cm)'**
  String get profileHeight;

  /// No description provided for @profileCurrentWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso actual (kg)'**
  String get profileCurrentWeight;

  /// No description provided for @profileTargetWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso objetivo (kg)'**
  String get profileTargetWeight;

  /// No description provided for @profileActivityLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de actividad física'**
  String get profileActivityLevel;

  /// No description provided for @profileActivitySedentary.
  ///
  /// In es, this message translates to:
  /// **'Sedentario'**
  String get profileActivitySedentary;

  /// No description provided for @profileActivityLight.
  ///
  /// In es, this message translates to:
  /// **'Actividad ligera'**
  String get profileActivityLight;

  /// No description provided for @profileActivityModerate.
  ///
  /// In es, this message translates to:
  /// **'Actividad moderada'**
  String get profileActivityModerate;

  /// No description provided for @profileActivityActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get profileActivityActive;

  /// No description provided for @profileActivityVeryActive.
  ///
  /// In es, this message translates to:
  /// **'Muy activo'**
  String get profileActivityVeryActive;

  /// No description provided for @profileAllergies.
  ///
  /// In es, this message translates to:
  /// **'Alergias'**
  String get profileAllergies;

  /// No description provided for @profileRestrictions.
  ///
  /// In es, this message translates to:
  /// **'Restricciones alimentarias'**
  String get profileRestrictions;

  /// No description provided for @profileSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar perfil'**
  String get profileSaveButton;

  /// No description provided for @profileSavedMessage.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado correctamente'**
  String get profileSavedMessage;

  /// No description provided for @goalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Objetivos nutricionales'**
  String get goalsTitle;

  /// No description provided for @goalLoseWeight.
  ///
  /// In es, this message translates to:
  /// **'Perder peso'**
  String get goalLoseWeight;

  /// No description provided for @goalGainMuscle.
  ///
  /// In es, this message translates to:
  /// **'Aumentar masa muscular'**
  String get goalGainMuscle;

  /// No description provided for @goalMaintainWeight.
  ///
  /// In es, this message translates to:
  /// **'Mantener peso'**
  String get goalMaintainWeight;

  /// No description provided for @goalReduceCholesterol.
  ///
  /// In es, this message translates to:
  /// **'Reducir colesterol'**
  String get goalReduceCholesterol;

  /// No description provided for @goalControlDiabetes.
  ///
  /// In es, this message translates to:
  /// **'Controlar diabetes'**
  String get goalControlDiabetes;

  /// No description provided for @goalRegulateSugar.
  ///
  /// In es, this message translates to:
  /// **'Regular azúcar'**
  String get goalRegulateSugar;

  /// No description provided for @goalHealthyEating.
  ///
  /// In es, this message translates to:
  /// **'Alimentación saludable'**
  String get goalHealthyEating;

  /// No description provided for @goalReduceBodyFat.
  ///
  /// In es, this message translates to:
  /// **'Reducir grasa corporal'**
  String get goalReduceBodyFat;

  /// No description provided for @goalImprovePerformance.
  ///
  /// In es, this message translates to:
  /// **'Mejorar rendimiento deportivo'**
  String get goalImprovePerformance;

  /// No description provided for @dashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel principal'**
  String get dashboardTitle;

  /// No description provided for @dashboardCaloriesConsumed.
  ///
  /// In es, this message translates to:
  /// **'Calorías consumidas'**
  String get dashboardCaloriesConsumed;

  /// No description provided for @dashboardCaloriesRemaining.
  ///
  /// In es, this message translates to:
  /// **'Calorías restantes'**
  String get dashboardCaloriesRemaining;

  /// No description provided for @dashboardProtein.
  ///
  /// In es, this message translates to:
  /// **'Proteína'**
  String get dashboardProtein;

  /// No description provided for @dashboardCarbs.
  ///
  /// In es, this message translates to:
  /// **'Carbohidratos'**
  String get dashboardCarbs;

  /// No description provided for @dashboardFat.
  ///
  /// In es, this message translates to:
  /// **'Grasas'**
  String get dashboardFat;

  /// No description provided for @dashboardWater.
  ///
  /// In es, this message translates to:
  /// **'Agua'**
  String get dashboardWater;

  /// No description provided for @dashboardDailyGoal.
  ///
  /// In es, this message translates to:
  /// **'Objetivo diario'**
  String get dashboardDailyGoal;

  /// No description provided for @dashboardProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get dashboardProgress;

  /// No description provided for @dashboardCurrentWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso actual'**
  String get dashboardCurrentWeight;

  /// No description provided for @dashboardTodayMeals.
  ///
  /// In es, this message translates to:
  /// **'Comidas de hoy'**
  String get dashboardTodayMeals;

  /// No description provided for @dashboardNoMealsYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado comidas hoy'**
  String get dashboardNoMealsYet;

  /// No description provided for @dashboardAddMeal.
  ///
  /// In es, this message translates to:
  /// **'Agregar comida'**
  String get dashboardAddMeal;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In es, this message translates to:
  /// **'Desayuno'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeMorningSnack.
  ///
  /// In es, this message translates to:
  /// **'Merienda mañana'**
  String get mealTypeMorningSnack;

  /// No description provided for @mealTypeLunch.
  ///
  /// In es, this message translates to:
  /// **'Almuerzo'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeAfternoonSnack.
  ///
  /// In es, this message translates to:
  /// **'Merienda tarde'**
  String get mealTypeAfternoonSnack;

  /// No description provided for @mealTypeDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeDrink.
  ///
  /// In es, this message translates to:
  /// **'Bebida'**
  String get mealTypeDrink;

  /// No description provided for @mealTypeDessert.
  ///
  /// In es, this message translates to:
  /// **'Postre'**
  String get mealTypeDessert;

  /// No description provided for @foodLogTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar comida'**
  String get foodLogTitle;

  /// No description provided for @foodLogTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get foodLogTakePhoto;

  /// No description provided for @foodLogChooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get foodLogChooseFromGallery;

  /// No description provided for @foodLogAnalyzing.
  ///
  /// In es, this message translates to:
  /// **'Analizando alimento...'**
  String get foodLogAnalyzing;

  /// No description provided for @foodLogAnalysisResult.
  ///
  /// In es, this message translates to:
  /// **'Resultado del análisis'**
  String get foodLogAnalysisResult;

  /// No description provided for @foodLogConfidenceLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de confianza'**
  String get foodLogConfidenceLevel;

  /// No description provided for @foodLogConfidenceHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get foodLogConfidenceHigh;

  /// No description provided for @foodLogConfidenceMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get foodLogConfidenceMedium;

  /// No description provided for @foodLogConfidenceLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get foodLogConfidenceLow;

  /// No description provided for @foodLogNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get foodLogNotAvailable;

  /// No description provided for @foodLogFoodName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del alimento'**
  String get foodLogFoodName;

  /// No description provided for @foodLogPortionSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de la porción'**
  String get foodLogPortionSize;

  /// No description provided for @foodLogServings.
  ///
  /// In es, this message translates to:
  /// **'Número de porciones'**
  String get foodLogServings;

  /// No description provided for @foodLogManualEntry.
  ///
  /// In es, this message translates to:
  /// **'Ingresar manualmente'**
  String get foodLogManualEntry;

  /// No description provided for @foodLogSaveEntry.
  ///
  /// In es, this message translates to:
  /// **'Guardar registro'**
  String get foodLogSaveEntry;

  /// No description provided for @foodLogEntrySaved.
  ///
  /// In es, this message translates to:
  /// **'Comida registrada correctamente'**
  String get foodLogEntrySaved;

  /// No description provided for @foodLogEditClassification.
  ///
  /// In es, this message translates to:
  /// **'Editar clasificación'**
  String get foodLogEditClassification;

  /// No description provided for @foodLogCalories.
  ///
  /// In es, this message translates to:
  /// **'Calorías'**
  String get foodLogCalories;

  /// No description provided for @foodLogSaturatedFat.
  ///
  /// In es, this message translates to:
  /// **'Grasas saturadas'**
  String get foodLogSaturatedFat;

  /// No description provided for @foodLogTransFat.
  ///
  /// In es, this message translates to:
  /// **'Grasas trans'**
  String get foodLogTransFat;

  /// No description provided for @foodLogFiber.
  ///
  /// In es, this message translates to:
  /// **'Fibra'**
  String get foodLogFiber;

  /// No description provided for @foodLogSugars.
  ///
  /// In es, this message translates to:
  /// **'Azúcares'**
  String get foodLogSugars;

  /// No description provided for @foodLogSodium.
  ///
  /// In es, this message translates to:
  /// **'Sodio'**
  String get foodLogSodium;

  /// No description provided for @foodLogCholesterol.
  ///
  /// In es, this message translates to:
  /// **'Colesterol'**
  String get foodLogCholesterol;

  /// No description provided for @foodLogVitamins.
  ///
  /// In es, this message translates to:
  /// **'Vitaminas principales'**
  String get foodLogVitamins;

  /// No description provided for @foodLogMinerals.
  ///
  /// In es, this message translates to:
  /// **'Minerales principales'**
  String get foodLogMinerals;

  /// No description provided for @pantryTitle.
  ///
  /// In es, this message translates to:
  /// **'Despensa'**
  String get pantryTitle;

  /// No description provided for @pantryAddItem.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get pantryAddItem;

  /// No description provided for @pantryCategoryFruits.
  ///
  /// In es, this message translates to:
  /// **'Frutas'**
  String get pantryCategoryFruits;

  /// No description provided for @pantryCategoryVegetables.
  ///
  /// In es, this message translates to:
  /// **'Vegetales'**
  String get pantryCategoryVegetables;

  /// No description provided for @pantryCategoryMeats.
  ///
  /// In es, this message translates to:
  /// **'Carnes'**
  String get pantryCategoryMeats;

  /// No description provided for @pantryCategoryFish.
  ///
  /// In es, this message translates to:
  /// **'Pescados'**
  String get pantryCategoryFish;

  /// No description provided for @pantryCategorySeafood.
  ///
  /// In es, this message translates to:
  /// **'Mariscos'**
  String get pantryCategorySeafood;

  /// No description provided for @pantryCategoryDairy.
  ///
  /// In es, this message translates to:
  /// **'Lácteos'**
  String get pantryCategoryDairy;

  /// No description provided for @pantryCategoryGrains.
  ///
  /// In es, this message translates to:
  /// **'Cereales'**
  String get pantryCategoryGrains;

  /// No description provided for @pantryCategoryLegumes.
  ///
  /// In es, this message translates to:
  /// **'Legumbres'**
  String get pantryCategoryLegumes;

  /// No description provided for @pantryCategorySnacks.
  ///
  /// In es, this message translates to:
  /// **'Snacks'**
  String get pantryCategorySnacks;

  /// No description provided for @pantryCategoryBeverages.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get pantryCategoryBeverages;

  /// No description provided for @pantryCategoryFrozen.
  ///
  /// In es, this message translates to:
  /// **'Congelados'**
  String get pantryCategoryFrozen;

  /// No description provided for @pantryCategoryCondiments.
  ///
  /// In es, this message translates to:
  /// **'Condimentos'**
  String get pantryCategoryCondiments;

  /// No description provided for @pantryProductName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get pantryProductName;

  /// No description provided for @pantryQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad disponible'**
  String get pantryQuantity;

  /// No description provided for @pantryUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get pantryUnit;

  /// No description provided for @pantryPurchaseDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de compra'**
  String get pantryPurchaseDate;

  /// No description provided for @pantryExpirationDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get pantryExpirationDate;

  /// No description provided for @pantryDaysRemaining.
  ///
  /// In es, this message translates to:
  /// **'Días restantes'**
  String get pantryDaysRemaining;

  /// No description provided for @pantryExpiringSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximo a vencer'**
  String get pantryExpiringSoon;

  /// No description provided for @pantryExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get pantryExpired;

  /// No description provided for @pantryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu despensa está vacía'**
  String get pantryEmpty;

  /// No description provided for @pantrySaveItem.
  ///
  /// In es, this message translates to:
  /// **'Guardar producto'**
  String get pantrySaveItem;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get settingsEditProfile;

  /// No description provided for @settingsChangeGoal.
  ///
  /// In es, this message translates to:
  /// **'Cambiar objetivo'**
  String get settingsChangeGoal;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsExportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar información'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todos los datos'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar todos los datos?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer. Se eliminará toda tu información almacenada en el dispositivo.'**
  String get settingsDeleteConfirmMessage;

  /// No description provided for @settingsCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get settingsCancel;

  /// No description provided for @settingsConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get settingsConfirm;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get commonRequired;

  /// No description provided for @commonToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get commonYesterday;

  /// No description provided for @commonKg.
  ///
  /// In es, this message translates to:
  /// **'kg'**
  String get commonKg;

  /// No description provided for @commonCm.
  ///
  /// In es, this message translates to:
  /// **'cm'**
  String get commonCm;

  /// No description provided for @commonKcal.
  ///
  /// In es, this message translates to:
  /// **'kcal'**
  String get commonKcal;

  /// No description provided for @commonGrams.
  ///
  /// In es, this message translates to:
  /// **'g'**
  String get commonGrams;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
