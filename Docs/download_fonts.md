# 📥 Descarga Rápida de Fuentes Inter + Manrope

## Opción 1: Descarga Manual (Recomendada)

### Inter
1. **Visita:** https://fonts.google.com/specimen/Inter
2. **Clic en:** "Get font" (botón azul superior derecha)
3. **Clic en:** "Download all"
4. **Descomprime** el ZIP descargado
5. **Ve a** la carpeta `static/`
6. **Copia estos archivos** a la carpeta `fonts/` del proyecto:
   ```
   Inter-Regular.ttf
   Inter-Medium.ttf
   Inter-SemiBold.ttf
   Inter-Bold.ttf
   ```

### Manrope
1. **Visita:** https://fonts.google.com/specimen/Manrope
2. **Clic en:** "Get font" (botón azul superior derecha)
3. **Clic en:** "Download all"
4. **Descomprime** el ZIP descargado
5. **Ve a** la carpeta `static/`
6. **Copia estos archivos** a la carpeta `fonts/` del proyecto:
   ```
   Manrope-Regular.ttf
   Manrope-Medium.ttf
   Manrope-SemiBold.ttf
   Manrope-Bold.ttf
   Manrope-ExtraBold.ttf
   ```

---

## Opción 2: Enlaces Directos de Descarga

Si prefieres descargar directamente (pueden cambiar con el tiempo):

### Inter (GitHub)
```
https://github.com/rsms/inter/releases/latest
```
Descarga `Inter-<version>.zip`, descomprime y copia los archivos de `Inter Desktop/` o `static/`

### Manrope (GitHub)
```
https://github.com/sharanda/manrope/releases
```
O desde Google Fonts directamente.

---

## ✅ Verificación

Después de copiar las fuentes, tu carpeta `fonts/` debe tener:

```
fonts/
├── Inter-Regular.ttf        ✅ Nuevo
├── Inter-Medium.ttf         ✅ Nuevo
├── Inter-SemiBold.ttf       ✅ Nuevo
├── Inter-Bold.ttf           ✅ Nuevo
├── Manrope-Regular.ttf      ✅ Nuevo
├── Manrope-Medium.ttf       ✅ Nuevo
├── Manrope-SemiBold.ttf     ✅ Nuevo
├── Manrope-Bold.ttf         ✅ Nuevo
├── Manrope-ExtraBold.ttf    ✅ Nuevo
├── Garet-Book.ttf           (Mantener)
├── LilitaOne-Regular.ttf    (Mantener)
└── SEGOEUI.ttf              (Mantener)
```

---

## 🚀 Ejecutar la App

Una vez copiadas las fuentes:

```bash
flutter pub get
flutter clean
flutter run
```

---

## 🎨 Resultado Esperado

Después de instalar las fuentes, verás:
- ✅ Textos más modernos y limpios
- ✅ Mejor legibilidad en pantallas pequeñas
- ✅ Títulos con personalidad (Manrope)
- ✅ Cuerpo de texto profesional (Inter)
- ✅ Look de app premium/tecnológica

---

## ⚠️ Troubleshooting

### "Font not found" error
1. Verifica que los archivos .ttf están en `fonts/`
2. Los nombres deben coincidir exactamente (mayúsculas/minúsculas)
3. Ejecuta `flutter pub get` después de copiar
4. Reinicia la app con `flutter run` (no hot reload)

### Las fuentes se ven raras
1. Asegúrate de haber copiado TODOS los pesos (Regular, Medium, SemiBold, Bold)
2. Verifica que los archivos no estén corruptos
3. Descarga nuevamente desde Google Fonts si es necesario

### Quiero volver a las fuentes anteriores
1. Ve a `lib/core/theme/app_tokens.dart`
2. Cambia:
   ```dart
   static const String fontFamilyPrimary = 'Garet';
   static const String fontFamilyDisplay = 'LilitaOne';
   ```
3. Hot restart

---

## 📚 Más Información

Ver documentación completa en: [Docs/FONT_SETUP.md](Docs/FONT_SETUP.md)
