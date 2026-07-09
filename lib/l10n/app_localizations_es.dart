// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'NutriApp';

  @override
  String get authWelcomeTitle => 'Bienvenido a NutriApp';

  @override
  String get authWelcomeSubtitle => 'Tu nutrición, con inteligencia artificial';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authLoginButton => 'Iniciar sesión';

  @override
  String get authRegisterButton => 'Registrarse';

  @override
  String get authRegisterLink => '¿No tienes cuenta? Regístrate';

  @override
  String get authLoginLink => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authLogoutButton => 'Cerrar sesión';

  @override
  String get authInvalidEmail => 'Correo electrónico no válido';

  @override
  String get authPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authEmailAlreadyExists => 'Ya existe una cuenta con este correo';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get authGoogleComingSoon => 'Inicio de sesión con Google próximamente';

  @override
  String get authMicrosoftComingSoon =>
      'Inicio de sesión con Microsoft próximamente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileBirthDate => 'Fecha de nacimiento';

  @override
  String get profileSex => 'Sexo';

  @override
  String get profileSexMale => 'Masculino';

  @override
  String get profileSexFemale => 'Femenino';

  @override
  String get profileSexOther => 'Otro';

  @override
  String get profileHeight => 'Estatura (cm)';

  @override
  String get profileCurrentWeight => 'Peso actual (kg)';

  @override
  String get profileTargetWeight => 'Peso objetivo (kg)';

  @override
  String get profileActivityLevel => 'Nivel de actividad física';

  @override
  String get profileActivitySedentary => 'Sedentario';

  @override
  String get profileActivityLight => 'Actividad ligera';

  @override
  String get profileActivityModerate => 'Actividad moderada';

  @override
  String get profileActivityActive => 'Activo';

  @override
  String get profileActivityVeryActive => 'Muy activo';

  @override
  String get profileAllergies => 'Alergias';

  @override
  String get profileRestrictions => 'Restricciones alimentarias';

  @override
  String get profileSaveButton => 'Guardar perfil';

  @override
  String get profileSavedMessage => 'Perfil guardado correctamente';

  @override
  String get goalsTitle => 'Objetivos nutricionales';

  @override
  String get goalLoseWeight => 'Perder peso';

  @override
  String get goalGainMuscle => 'Aumentar masa muscular';

  @override
  String get goalMaintainWeight => 'Mantener peso';

  @override
  String get goalReduceCholesterol => 'Reducir colesterol';

  @override
  String get goalControlDiabetes => 'Controlar diabetes';

  @override
  String get goalRegulateSugar => 'Regular azúcar';

  @override
  String get goalHealthyEating => 'Alimentación saludable';

  @override
  String get goalReduceBodyFat => 'Reducir grasa corporal';

  @override
  String get goalImprovePerformance => 'Mejorar rendimiento deportivo';

  @override
  String get dashboardTitle => 'Panel principal';

  @override
  String get dashboardCaloriesConsumed => 'Calorías consumidas';

  @override
  String get dashboardCaloriesRemaining => 'Calorías restantes';

  @override
  String get dashboardProtein => 'Proteína';

  @override
  String get dashboardCarbs => 'Carbohidratos';

  @override
  String get dashboardFat => 'Grasas';

  @override
  String get dashboardWater => 'Agua';

  @override
  String get dashboardDailyGoal => 'Objetivo diario';

  @override
  String get dashboardProgress => 'Progreso';

  @override
  String get dashboardCurrentWeight => 'Peso actual';

  @override
  String get dashboardTodayMeals => 'Comidas de hoy';

  @override
  String get dashboardNoMealsYet => 'Aún no has registrado comidas hoy';

  @override
  String get dashboardAddMeal => 'Agregar comida';

  @override
  String get mealTypeBreakfast => 'Desayuno';

  @override
  String get mealTypeMorningSnack => 'Merienda mañana';

  @override
  String get mealTypeLunch => 'Almuerzo';

  @override
  String get mealTypeAfternoonSnack => 'Merienda tarde';

  @override
  String get mealTypeDinner => 'Cena';

  @override
  String get mealTypeDrink => 'Bebida';

  @override
  String get mealTypeDessert => 'Postre';

  @override
  String get foodLogTitle => 'Registrar comida';

  @override
  String get foodLogTakePhoto => 'Tomar foto';

  @override
  String get foodLogChooseFromGallery => 'Elegir de la galería';

  @override
  String get foodLogAnalyzing => 'Analizando alimento...';

  @override
  String get foodLogAnalysisResult => 'Resultado del análisis';

  @override
  String get foodLogConfidenceLevel => 'Nivel de confianza';

  @override
  String get foodLogConfidenceHigh => 'Alta';

  @override
  String get foodLogConfidenceMedium => 'Media';

  @override
  String get foodLogConfidenceLow => 'Baja';

  @override
  String get foodLogNotAvailable => 'No disponible';

  @override
  String get foodLogFoodName => 'Nombre del alimento';

  @override
  String get foodLogPortionSize => 'Tamaño de la porción';

  @override
  String get foodLogServings => 'Número de porciones';

  @override
  String get foodLogManualEntry => 'Ingresar manualmente';

  @override
  String get foodLogSaveEntry => 'Guardar registro';

  @override
  String get foodLogEntrySaved => 'Comida registrada correctamente';

  @override
  String get foodLogEditClassification => 'Editar clasificación';

  @override
  String get foodLogCalories => 'Calorías';

  @override
  String get foodLogSaturatedFat => 'Grasas saturadas';

  @override
  String get foodLogTransFat => 'Grasas trans';

  @override
  String get foodLogFiber => 'Fibra';

  @override
  String get foodLogSugars => 'Azúcares';

  @override
  String get foodLogSodium => 'Sodio';

  @override
  String get foodLogCholesterol => 'Colesterol';

  @override
  String get foodLogVitamins => 'Vitaminas principales';

  @override
  String get foodLogMinerals => 'Minerales principales';

  @override
  String get pantryTitle => 'Despensa';

  @override
  String get pantryAddItem => 'Agregar producto';

  @override
  String get pantryCategoryFruits => 'Frutas';

  @override
  String get pantryCategoryVegetables => 'Vegetales';

  @override
  String get pantryCategoryMeats => 'Carnes';

  @override
  String get pantryCategoryFish => 'Pescados';

  @override
  String get pantryCategorySeafood => 'Mariscos';

  @override
  String get pantryCategoryDairy => 'Lácteos';

  @override
  String get pantryCategoryGrains => 'Cereales';

  @override
  String get pantryCategoryLegumes => 'Legumbres';

  @override
  String get pantryCategorySnacks => 'Snacks';

  @override
  String get pantryCategoryBeverages => 'Bebidas';

  @override
  String get pantryCategoryFrozen => 'Congelados';

  @override
  String get pantryCategoryCondiments => 'Condimentos';

  @override
  String get pantryProductName => 'Nombre del producto';

  @override
  String get pantryQuantity => 'Cantidad disponible';

  @override
  String get pantryUnit => 'Unidad';

  @override
  String get pantryPurchaseDate => 'Fecha de compra';

  @override
  String get pantryExpirationDate => 'Fecha de vencimiento';

  @override
  String get pantryDaysRemaining => 'Días restantes';

  @override
  String get pantryExpiringSoon => 'Próximo a vencer';

  @override
  String get pantryExpired => 'Vencido';

  @override
  String get pantryEmpty => 'Tu despensa está vacía';

  @override
  String get pantrySaveItem => 'Guardar producto';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsChangeGoal => 'Cambiar objetivo';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsExportData => 'Exportar información';

  @override
  String get settingsDeleteAllData => 'Eliminar todos los datos';

  @override
  String get settingsDeleteConfirmTitle => '¿Eliminar todos los datos?';

  @override
  String get settingsDeleteConfirmMessage =>
      'Esta acción no se puede deshacer. Se eliminará toda tu información almacenada en el dispositivo.';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String get settingsConfirm => 'Confirmar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Ocurrió un error';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonRequired => 'Este campo es obligatorio';

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonYesterday => 'Ayer';

  @override
  String get commonKg => 'kg';

  @override
  String get commonCm => 'cm';

  @override
  String get commonKcal => 'kcal';

  @override
  String get commonGrams => 'g';
}
