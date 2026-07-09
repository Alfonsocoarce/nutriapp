# Especificación de Requerimientos del Software (ERS)

## NutriApp — Aplicación Móvil Inteligente de Nutrición y Planificación Alimentaria con Inteligencia Artificial

### Plataforma
- Android
- iOS

### Idioma
Toda la interfaz, textos, notificaciones, mensajes de error y configuración de la aplicación
estarán en **español**.

---

## 1. Objetivo General

Desarrollar una aplicación móvil para Android e iOS que utilice Inteligencia Artificial para ayudar
a los usuarios a mejorar su alimentación mediante el análisis de fotografías de alimentos, el
cálculo automático de calorías y nutrientes, la administración de la despensa del hogar y la
generación de planes alimenticios personalizados basados en evidencia científica.

La aplicación deberá funcionar bajo un enfoque **Local First**, almacenando toda la información
del usuario en el dispositivo y utilizando Internet únicamente cuando sea necesario para funciones
de Inteligencia Artificial o respaldo opcional.

## 2. Requerimientos Funcionales

### RF-01 Registro e Inicio de Sesión

- Registrarse mediante correo electrónico.
- Iniciar sesión con Google.
- Iniciar sesión con Microsoft (Outlook, Hotmail, Live u Office 365).
- Recuperar contraseña.
- Mantener la sesión iniciada.
- Cerrar sesión.

> **Nota de implementación (fase MVP):** el inicio de sesión con Google/Microsoft requiere cuentas
> de proveedor externas (Firebase/Supabase) que aún no están configuradas. La primera versión
> implementa únicamente registro/inicio de sesión local con correo y contraseña (almacenados de
> forma cifrada en el dispositivo, sin conexión). El acceso mediante Google/Microsoft queda
> documentado como fase posterior detrás de una interfaz `AuthService` intercambiable.

### RF-02 Perfil del Usuario

Nombre, fecha de nacimiento, sexo, estatura, peso actual, peso objetivo, nivel de actividad física,
objetivo nutricional, restricciones alimentarias, alergias, enfermedades (opcional).

### RF-03 Objetivos Nutricionales

Perder peso, aumentar masa muscular, mantener peso, reducir colesterol, controlar diabetes, regular
azúcar, alimentación saludable, reducir grasa corporal, mejorar rendimiento deportivo.

### RF-04 Captura de Fotografías

Tomar fotografías desde la cámara, seleccionar desde la galería, analizar varias fotografías
consecutivas.

### RF-05 Identificación Automática de Alimentos

La IA identificará: nombre del alimento, ingredientes, método de cocción, peso aproximado,
cantidad estimada, número de porciones y **nivel de confianza** de la identificación.

> **Principio de integridad de datos:** cuando la IA no pueda determinar un dato con confianza
> suficiente, la aplicación debe mostrarlo explícitamente como "no disponible" en vez de asumir un
> valor (p. ej. no rellenar micronutrientes faltantes con cero). Es preferible mostrar un vacío que
> un dato incorrecto.

### RF-06 Información Nutricional

Calorías, proteínas, carbohidratos, grasas, grasas saturadas, grasas trans, fibra, azúcares, sodio,
colesterol, vitaminas principales, minerales principales. Mostrada mediante tarjetas visuales,
tabla nutricional y gráficos simples. Aplica el mismo principio de integridad de datos de RF-05.

### RF-07 Registro Automático

Cada fotografía se almacena junto con fecha, hora, imagen, tipo de comida e información nutricional.

### RF-08 Clasificación Automática

Desayuno, merienda mañana, almuerzo, merienda tarde, cena, bebida, postre. El usuario puede
modificar la clasificación.

### RF-09 Escaneo de Facturas

Carga de facturas impresas, electrónicas o fotografiadas. La IA extrae producto, cantidad, unidad,
fecha y precio (opcional).

### RF-10 Registro Manual de Compras

Producto, cantidad, unidad, fecha de compra, fecha de vencimiento — vía factura o ingreso manual.

### RF-11 Despensa Inteligente

Categorías: frutas, vegetales, carnes, pescados, mariscos, lácteos, cereales, legumbres, snacks,
bebidas, congelados, condimentos. Cada producto muestra cantidad disponible, fecha de compra, fecha
de vencimiento y días restantes.

### RF-12 Planificador Inteligente

Genera plan diario y semanal usando objetivos, despensa, restricciones, preferencias, historial y
calorías restantes.

> **Adiciones (basadas en análisis de aplicaciones comparables):**
> - **Recetas recursivas/composables**: una receta puede estar compuesta por otras recetas (p. ej.
>   un pastel = receta de masa + receta de relleno), agregando la información nutricional de forma
>   recursiva hacia arriba.
> - **Duplicar día**: el usuario puede copiar todas las comidas de un día a otra fecha (pasada o
>   futura), agilizando la planificación semanal repetitiva.

### RF-13 Recomendación de Porciones

Proteína, carbohidratos, vegetales y grasas saludables, ajustadas según edad, sexo, peso, estatura,
nivel de actividad y objetivo.

### RF-14 Recomendaciones Inteligentes

Consumir más proteína, reducir azúcar, reducir sodio, incrementar fibra, aumentar vegetales, reducir
grasas saturadas, utilizar alimentos próximos a vencer.

### RF-15 Asistente Nutricional

Consultas en lenguaje natural (¿qué puedo cocinar?, ¿qué puedo desayunar/cenar?, ¿puedo comer esto?,
¿qué alimento tiene más proteína?, ¿cómo alcanzo mi meta?) usando inventario, historial, objetivos y
calorías disponibles.

### RF-16 Escáner de Código de Barras

Información nutricional, ingredientes, alérgenos y tamaño de porción.

### RF-17 Panel Principal

Calorías consumidas/restantes, proteína, carbohidratos, grasas, agua, objetivo diario, progreso,
peso actual.

### RF-18 Resumen Semanal

Reporte automático de lunes 12:00 a.m. a domingo 5:00 p.m.: totales de calorías, proteínas,
carbohidratos, grasas, fibra, azúcar, sodio, colesterol, cantidad de comidas, distribución por
categorías y cumplimiento de objetivos.

### RF-19 Estadísticas

Consumo diario, semanal, mensual; evolución del peso; macronutrientes; cumplimiento de metas.

### RF-20 Exportación

PDF, Excel, CSV.

> **Nota de implementación:** documentar el formato de exportación (esquema de columnas/campos) en
> `docs/export-format.md` antes de implementar, para que no varíe entre versiones.

### RF-21 Notificaciones

Registrar comidas, beber agua, comer, comprar alimentos, consumir alimentos próximos a vencer,
consultar el resumen semanal.

### RF-22 Historial

Fotografías, planes, reportes, peso, objetivos, estadísticas.

### RF-23 Configuración

Editar perfil, cambiar objetivo, cambiar idioma, activar/desactivar notificaciones, exportar
información, eliminar todos los datos, cerrar sesión.

## 3. Requerimientos de Inteligencia Artificial

- Identificar alimentos mediante fotografías.
- Estimar porciones.
- Calcular calorías y macronutrientes; micronutrientes cuando sea posible.
- Recomendar porciones y generar planes alimenticios.
- Analizar hábitos alimenticios; detectar excesos de azúcar, sodio y grasas; detectar deficiencias
  nutricionales.
- Recomendar mejoras alimenticias y adaptarse conforme aprende de los hábitos del usuario.

> **Requisito de seguridad (nuevo):** las llamadas a los modelos de visión por IA deben pasar por un
> **backend/proxy delgado y sin estado** (stateless). La clave de la API de IA (OpenAI/Gemini Vision)
> **nunca** debe incluirse en el binario de la aplicación móvil — es trivialmente extraíble. El
> proxy únicamente reenvía la solicitud de foto → resultado, sin almacenar datos de usuario,
> preservando el enfoque Local First para todo lo demás.
>
> **Optimización recomendada:** cachear resultados de comidas repetidas (por hash o embedding de
> imagen) antes de volver a invocar el modelo de visión, reduciendo costo y latencia.

## 4. Requerimientos de Almacenamiento — Arquitectura Local First

Toda la información del usuario (perfil, fotografías, resultados de análisis, historial, despensa,
facturas, reportes, configuración, estadísticas, objetivos) se almacena localmente, cifrada, y la
app funciona completamente sin conexión para consultar información ya almacenada.

Internet es necesario únicamente para: procesar nuevas fotografías mediante IA, actualizar bases
nutricionales, respaldos opcionales y actualizaciones de la aplicación.

El usuario puede eliminar todos sus datos en cualquier momento.

## 5. Requerimientos No Funcionales

- Compatible con Android 12+ e iOS 16+.
- Interfaz moderna, intuitiva y fácil de usar, completamente en español.
- Análisis de fotografías en menos de cinco segundos (objetivo).
- Arquitectura modular y escalable.
- Cifrado de la información.
- Accesibilidad WCAG 2.2 AA.
- Consumo eficiente de batería y almacenamiento.
- Experiencia fluida incluso con miles de registros.

## 6. Estándares Nutricionales

Basados en OMS, Dietary Reference Intakes (DRI), USDA MyPlate, American Heart Association, American
Diabetes Association, Academy of Nutrition and Dietetics y guías alimentarias oficiales del país
del usuario cuando estén disponibles.

Las recomendaciones son de carácter informativo/educativo y no sustituyen la atención de un médico
o nutricionista.

## 7. Tecnologías

- **Frontend:** Flutter (una sola base de código para Android e iOS).
- **Gestión de estado:** Riverpod.
- **Base de datos local:** Isar, cifrada.
- **Autenticación:** local (correo/contraseña) en la fase inicial; Firebase Authentication o
  Supabase Auth (Google, Microsoft) en fases posteriores.
- **IA de reconocimiento de alimentos:** OpenAI Vision o Google Gemini Vision, detrás de un proxy
  backend propio (ver Sección 3).
- **OCR de facturas:** Google ML Kit o Tesseract OCR.
- **Bases de datos nutricionales:** USDA FoodData Central, Open Food Facts y **Swiss Food
  Composition Database** (fuente adicional para mejorar la cobertura de micronutrientes).
- **Notificaciones:** Firebase Cloud Messaging y notificaciones locales.
- **Gráficos:** FL Chart.
- **Arquitectura:** Clean Architecture (data/domain/presentation).
- **Distribución:** automatización de builds/releases con Fastlane para ambas tiendas.

## 8. Características Diferenciadoras

Reconocimiento automático de alimentos por foto, estimación de porciones con IA, cálculo automático
de calorías/nutrientes, gestión inteligente de despensa (factura o manual), planificación
automática de comidas (incluyendo recetas recursivas y duplicación de días), recomendaciones
basadas en evidencia científica, seguimiento mediante paneles/gráficos/reportes, enfoque Local
First priorizando privacidad, compatibilidad Android/iOS con una sola base de código, y diseño
preparado para crecer (relojes inteligentes, recetas, menús de restaurantes, asistentes
conversacionales avanzados).

## 9. Fases de Construcción

**Fase 1 — MVP (actual):** RF-01 (solo correo/contraseña local), RF-02, RF-03, RF-06/07/08
(registro manual con reconocimiento de fotos simulado), RF-11 (despensa manual), RF-17 (panel
principal). Corre en simulador iOS y emulador Android.

**Fases siguientes (documentadas, no implementadas aún):** RF-04/05 con IA real (requiere clave de
API y proxy backend desplegado), RF-09 (OCR de facturas), RF-12 (planificador con IA), RF-13/14/15
(recomendaciones y asistente conversacional), RF-16 (código de barras), RF-18/19/20 (reportes y
exportación), RF-21 (notificaciones), inicio de sesión con Google/Microsoft.

---

*Este documento incorpora hallazgos de una investigación comparativa de aplicaciones open-source
similares (OpenNutriTracker, Caloriemate, PANTS, FoodYou, Mega-Fitness-App) realizada antes de
iniciar la construcción.*
