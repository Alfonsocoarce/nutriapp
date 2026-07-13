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
  String get navDashboard => 'Inicio';

  @override
  String get navFoodLog => 'Registrar';

  @override
  String get navPantry => 'Despensa';

  @override
  String get navReports => 'Resumen';

  @override
  String get navSettings => 'Configuración';

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
  String get dashboardYourGoalsTitle => 'Tus objetivos';

  @override
  String get dashboardYourGoalsSubtitle =>
      'Puedes cambiarlos cuando quieras en Configuración → Editar perfil — la IA ajustará tus planes y recomendaciones automáticamente.';

  @override
  String get dashboardYourGoalsEmpty =>
      'Aún no has seleccionado objetivos nutricionales. Agrégalos en Configuración → Editar perfil.';

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
  String get foodLogVisibilityTip =>
      'Consejo: toma la foto desde arriba y asegúrate de que todos los alimentos del plato sean visibles (evita que unos tapen a otros) para un cálculo más preciso de las porciones.';

  @override
  String get foodLogVisibilityWarningTitle =>
      'Revisa las porciones antes de guardar';

  @override
  String get foodLogImprovementTipTitle =>
      'Cómo obtener un resultado más preciso';

  @override
  String get foodLogComponentBreakdownTitle => 'Desglose por alimento';

  @override
  String get foodLogLoveMessage => 'Te amo, cuida siempre tu salud';

  @override
  String get foodLogModeMeal => 'Plato de comida';

  @override
  String get foodLogModeLabel => 'Producto con etiqueta';

  @override
  String get foodLogLabelTip =>
      'Consejo: encuadra toda la tabla de Datos Nutricionales, sin reflejos ni partes cortadas, para leer los valores impresos con precisión.';

  @override
  String get reportsTitle => 'Resumen semanal';

  @override
  String get reportsGeneratePdf => 'Generar resumen y recomendaciones';

  @override
  String get reportsGenerating => 'Generando resumen...';

  @override
  String get reportsGeneratedSnackbar =>
      'Resumen generado y listo para compartir';

  @override
  String get reportsGenerationFailed =>
      'No se pudo generar el resumen. Intenta de nuevo.';

  @override
  String get reportsNoProfile =>
      'Completa tu perfil para generar resúmenes semanales.';

  @override
  String get reportsAverages => 'Promedios de los últimos 7 días';

  @override
  String get reportsDaysLogged => 'Días con registros';

  @override
  String get reportsGoal => 'Meta';

  @override
  String get reportsConsumed => 'Consumido';

  @override
  String get reportsPreviousReports => 'Reportes generados';

  @override
  String get reportsNoPreviousReports => 'Aún no has generado ningún reporte.';

  @override
  String get reportsShare => 'Compartir';

  @override
  String get reportsCaloriesChartTitle => 'Calorías por día';

  @override
  String get reportsTopFoods => 'Alimentos más consumidos';

  @override
  String get reportsNoEntriesThisDay => 'Sin registros';

  @override
  String get reportsShareSubject => 'Mi resumen semanal de NutriApp';

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
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get pantrySaveItem => 'Guardar producto';

  @override
  String get pantryUploadInvoice => 'Cargar factura del súper';

  @override
  String get pantryAddManually => 'Agregar manualmente';

  @override
  String get invoiceReviewTitle => 'Revisar factura';

  @override
  String get invoiceAnalyzing => 'Analizando factura...';

  @override
  String get invoiceReviewSubtitle =>
      'Confirma o corrige los productos detectados antes de guardarlos en tu despensa';

  @override
  String get invoiceReplaceWarning =>
      'Al guardar, esta lista reemplazará todos los productos actuales de tu despensa (incluidos los que agregaste a mano). Esta acción no se puede deshacer.';

  @override
  String get invoiceItemIncluded => 'Incluir este producto';

  @override
  String get invoiceSaveAll => 'Reemplazar despensa';

  @override
  String get invoiceItemsSaved =>
      'Despensa actualizada con los productos de la factura';

  @override
  String get invoiceReplaceConfirmTitle => '¿Reemplazar toda la despensa?';

  @override
  String get invoiceReplaceConfirmMessage =>
      'Se eliminarán todos los productos actuales de tu despensa y se reemplazarán por los de esta factura. Esta acción no se puede deshacer.';

  @override
  String get invoiceReplaceConfirmButton => 'Sí, reemplazar';

  @override
  String get invoiceNoFileSelected => 'No se seleccionó ningún archivo';

  @override
  String get invoiceParsingError =>
      'No se pudo leer la factura. Intenta de nuevo o agrega los productos manualmente.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsEditProfileDesc =>
      'Actualiza tus datos personales y tus objetivos nutricionales.';

  @override
  String get settingsChangeGoal => 'Cambiar objetivo';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsDesc =>
      'Recordatorios para registrar desayuno, almuerzo y cena.';

  @override
  String settingsNotificationsEnabledDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios activos',
      one: '1 recordatorio activo',
      zero: 'Todos los recordatorios desactivados',
    );
    return '$_temp0';
  }

  @override
  String get settingsNotificationsDialogTitle => 'Recordatorios de comidas';

  @override
  String get settingsNotificationsTimeLabel => 'Hora';

  @override
  String get settingsNotificationsBreakfastLabel => 'Desayuno';

  @override
  String get settingsNotificationsLunchLabel => 'Almuerzo';

  @override
  String get settingsNotificationsDinnerLabel => 'Cena';

  @override
  String get settingsNotificationsBreakfastPushTitle =>
      '¿Ya registraste tu desayuno?';

  @override
  String get settingsNotificationsLunchPushTitle =>
      '¿Ya registraste tu almuerzo?';

  @override
  String get settingsNotificationsDinnerPushTitle => '¿Ya registraste tu cena?';

  @override
  String get settingsNotificationsPushBody =>
      'Recuerda registrar tus alimentos para potenciar los resultados de tu dieta.';

  @override
  String get settingsNotificationsPermissionDenied =>
      'No se pudo activar: permite las notificaciones para NutriApp en los ajustes del sistema.';

  @override
  String get settingsReplayTutorialDesc =>
      'Vuelve a ver la guía de bienvenida con una explicación de cada parte de la app.';

  @override
  String get settingsExportData => 'Exportar información';

  @override
  String get settingsExportDataDesc =>
      'Descarga una copia de tu información almacenada en el dispositivo.';

  @override
  String get settingsExportShareSubject => 'Mis datos de NutriApp';

  @override
  String get settingsExportFailed =>
      'No se pudo exportar la información. Intenta de nuevo.';

  @override
  String get settingsDeleteAllData => 'Eliminar todos los datos';

  @override
  String get settingsDeleteAllDataDesc =>
      'Borra permanentemente tu información de este dispositivo. No se puede deshacer.';

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
  String get settingsSave => 'Guardar';

  @override
  String get settingsApiKeyTitle => 'Clave de API de IA (Gemini)';

  @override
  String get settingsApiKeySubtitleSet =>
      'Configurada en este dispositivo — el reconocimiento de fotos está activo para todas las cuentas que inicien sesión aquí';

  @override
  String get settingsApiKeySubtitleUnset =>
      'Sin configurar en este dispositivo — el reconocimiento de fotos no funcionará';

  @override
  String get settingsApiKeyDialogTitle => 'Clave de API de Gemini';

  @override
  String get settingsApiKeyDialogIntro =>
      'NutriApp usa Gemini Vision para identificar alimentos en tus fotos. Obtén una clave gratuita en:';

  @override
  String get settingsApiKeyDialogLinkLabel => 'aistudio.google.com/app/apikey';

  @override
  String get settingsApiKeyDialogOutro =>
      'Pégala aquí. Se guarda cifrada una sola vez en este dispositivo.';

  @override
  String get settingsApiKeyFieldLabel => 'Clave de API';

  @override
  String get settingsApiKeySave => 'Guardar clave';

  @override
  String get settingsApiKeyRemove => 'Quitar clave';

  @override
  String get settingsApiKeySaved => 'Clave guardada correctamente';

  @override
  String get settingsApiKeyRemoved => 'Clave eliminada';

  @override
  String get foodLogMissingApiKeyTitle => 'Falta configurar la IA';

  @override
  String get foodLogMissingApiKeyMessage =>
      'Para reconocer alimentos en fotos, primero agrega tu clave de API de Gemini en Configuración.';

  @override
  String get foodLogGoToSettings => 'Ir a Configuración';

  @override
  String get foodLogAnalysisFailedTitle => 'No se pudo analizar la foto';

  @override
  String get foodLogAnalysisFailedMessage =>
      'Verifica tu conexión a Internet y tu clave de API, o intenta de nuevo.';

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

  @override
  String get onboardingWelcomeDialogTitle => '¡Bienvenido/a a NutriApp!';

  @override
  String get onboardingWelcomeDialogMessage =>
      '¿Quieres un recorrido rápido para conocer cada parte de la app antes de empezar?';

  @override
  String get onboardingWelcomeDialogAccept => 'Ver recorrido';

  @override
  String get onboardingWelcomeDialogDecline => 'Ahora no';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingFinish => 'Comenzar';

  @override
  String get onboardingPage1Title => 'Panel principal';

  @override
  String get onboardingPage1Description =>
      'Tu resumen del día: calorías y macronutrientes consumidos frente a tu meta, tu peso actual y las comidas que ya registraste hoy.';

  @override
  String get onboardingPage2Title => 'Registrar comida';

  @override
  String get onboardingPage2Description =>
      'Toma una foto de tu plato o de la etiqueta de un producto envasado. La IA identifica los alimentos, estima las porciones y calcula la información nutricional automáticamente.';

  @override
  String get onboardingPage3Title => 'Despensa';

  @override
  String get onboardingPage3Description =>
      'Controla lo que tienes en casa: categorías y cantidades. Agrega productos a mano o escaneando la factura de tu supermercado.';

  @override
  String get onboardingPage4Title => 'Resumen semanal';

  @override
  String get onboardingPage4Description =>
      'Consulta tus calorías día a día, los alimentos que más consumes, y genera un PDF con recomendaciones nutricionales personalizadas listo para compartir.';

  @override
  String get onboardingPage5Title => 'Configuración';

  @override
  String get onboardingPage5Description =>
      'Edita tu perfil y objetivos, agrega tu clave de IA para el reconocimiento de fotos, y administra tus datos.';

  @override
  String get settingsReplayTutorial => 'Ver el recorrido de la app';
}
