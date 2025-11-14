# Configuración de Fuentes - Inter + Manrope

## 📥 Paso 1: Descargar las Fuentes

### Inter (Fuente primaria - cuerpo de texto)

1. Ve a [Google Fonts - Inter](https://fonts.google.com/specimen/Inter)
2. Haz clic en "Get font" → "Download all"
3. Descomprime el archivo ZIP
4. Ve a la carpeta `static/`
5. Copia estos archivos a `fonts/`:
   - `Inter-Regular.ttf` (400)
   - `Inter-Medium.ttf` (500)
   - `Inter-SemiBold.ttf` (600)
   - `Inter-Bold.ttf` (700)

**Alternativamente con Variable Font:**
- Copia `Inter-VariableFont_slnt,wght.ttf` → renombra a `Inter.ttf`

### Manrope (Fuente para títulos/displays)

1. Ve a [Google Fonts - Manrope](https://fonts.google.com/specimen/Manrope)
2. Haz clic en "Get font" → "Download all"
3. Descomprime el archivo ZIP
4. Ve a la carpeta `static/`
5. Copia estos archivos a `fonts/`:
   - `Manrope-Regular.ttf` (400)
   - `Manrope-Medium.ttf` (500)
   - `Manrope-SemiBold.ttf` (600)
   - `Manrope-Bold.ttf` (700)
   - `Manrope-ExtraBold.ttf` (800) - Opcional para displays

**Alternativamente con Variable Font:**
- Copia `Manrope-VariableFont_wght.ttf` → renombra a `Manrope.ttf`

---

## 📂 Estructura Final de Carpetas

Después de copiar las fuentes, tu carpeta `fonts/` debe verse así:

```
fonts/
├── Inter-Regular.ttf          # Nuevo
├── Inter-Medium.ttf           # Nuevo
├── Inter-SemiBold.ttf         # Nuevo
├── Inter-Bold.ttf             # Nuevo
├── Manrope-Regular.ttf        # Nuevo
├── Manrope-Medium.ttf         # Nuevo
├── Manrope-SemiBold.ttf       # Nuevo
├── Manrope-Bold.ttf           # Nuevo
├── Manrope-ExtraBold.ttf      # Nuevo (opcional)
├── Garet-Book.ttf             # Legacy (puedes eliminar después)
├── LilitaOne-Regular.ttf      # Legacy (puedes eliminar después)
└── SEGOEUI.ttf                # Legacy (puedes eliminar después)
```

---

## ⚡ Paso 2: Ejecutar Flutter Pub Get

Después de descargar y copiar las fuentes, ejecuta:

```bash
flutter pub get
flutter clean
flutter run
```

---

## 🎨 Características de las Fuentes

### Inter
- **Tipo:** Sans-serif humanista
- **Diseñador:** Rasmus Andersson
- **Características:**
  - Optimizada para legibilidad en pantallas
  - Espaciado perfecto para UI
  - Usada por: GitHub, Mozilla, Figma, Linear
  - Excelente para: Datos, tablas, texto corrido

### Manrope
- **Tipo:** Sans-serif geométrica
- **Diseñador:** Mikhail Sharanda
- **Características:**
  - Moderna y tecnológica
  - Geométrica pero accesible
  - Perfecta para: Títulos, números grandes, displays
  - Transmite: Innovación, limpieza, futuro

---

## 🔧 Configuración Aplicada

Ya he actualizado:
- ✅ `pubspec.yaml` - Declaración de fuentes
- ✅ `lib/core/theme/app_tokens.dart` - Familias de fuentes
- ✅ `lib/core/theme/app_theme.dart` - TextTheme usando Inter + Manrope

---

## 📱 Uso en la App

### Automático (Recomendado)
El TextTheme ya está configurado. Solo usa:

```dart
Text(
  'Título Grande',
  style: context.textStyles.headlineLarge, // Usa Manrope
)

Text(
  'Texto normal del cuerpo que explica algo importante',
  style: context.textStyles.bodyMedium, // Usa Inter
)
```

### Manual (Si necesitas)
```dart
Text(
  'Custom',
  style: TextStyle(
    fontFamily: AppTokens.fontFamilyPrimary,    // Inter
    fontSize: 16,
  ),
)

Text(
  'Display',
  style: TextStyle(
    fontFamily: AppTokens.fontFamilyDisplay,    // Manrope
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),
)
```

---

## 🎯 Jerarquía Visual

La configuración crea esta jerarquía:

**Manrope (Bold/ExtraBold):**
- Display: Números grandes, stats (ej: "1,500 kWh")
- Headlines: Títulos de sección (ej: "Tus movimientos mensuales")

**Manrope (SemiBold/Medium):**
- Titles: Títulos de cards/componentes

**Inter (Regular/Medium):**
- Body: Todo el texto corrido
- Labels: Botones, tabs, etiquetas
- Captions: Texto pequeño, fechas

---

## 🔍 Verificación

Para verificar que las fuentes están bien instaladas:

1. Ejecuta la app
2. Abre Chrome DevTools (si usas web) o usa Flutter Inspector
3. Verifica que no haya warnings de "Font not found"
4. Los textos deben verse modernos y limpios

Si ves warnings de fuentes, verifica:
- Los archivos .ttf están en `fonts/`
- Los nombres coinciden exactamente con `pubspec.yaml`
- Ejecutaste `flutter pub get`

---

## 💡 Tips de Uso

### Para Dashboards/Stats
```dart
Text(
  '1,500',
  style: TextStyle(
    fontFamily: 'Manrope',
    fontSize: 48,
    fontWeight: FontWeight.w800,  // ExtraBold
    letterSpacing: -1,  // Tighter para números grandes
  ),
)
```

### Para Tablas/Datos
```dart
Text(
  'Datos tabulares aquí',
  style: TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontFeatures: [FontFeature.tabularFigures()],  // Números alineados
  ),
)
```

### Para Moneda/Energía
```dart
Text(
  '\$ 15,000',
  style: TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
)
```

---

## 🎨 Comparación Visual

**Antes (Garet/SEGOEUI):**
- Garet: Fuente custom, puede no tener todos los pesos
- SEGOEUI: Sistema, inconsistente entre plataformas

**Después (Inter/Manrope):**
- ✅ Optimizadas para UI/UX
- ✅ Consistentes en todas las plataformas
- ✅ Open-source, siempre disponibles
- ✅ Usadas por apps líderes en tecnología
- ✅ Mejor legibilidad en pantallas pequeñas

---

## 📚 Referencias

- [Inter on Google Fonts](https://fonts.google.com/specimen/Inter)
- [Manrope on Google Fonts](https://fonts.google.com/specimen/Manrope)
- [Inter Repository](https://github.com/rsms/inter)
- [Manrope Repository](https://github.com/sharanda/manrope)

---

**¡Listo!** Una vez descargues las fuentes y ejecutes `flutter pub get`, la app tendrá un look profesional y moderno. 🚀
