# Constantes Económicas - Sistema P2P BeEnergy

## Valores Fundamentales - Enero 2026

### MC_m - Valor Energía / Precio Promedio de los Contratos
**Definición**: Precio promedio de los contratos de la simulación económica
**Valor**: `300.0 COP/kWh`
**Precisión**: 2 decimales (float)
**Uso**: Valor base para cálculos de rango de precios P2P

### Costo de Comercialización
**Valor**: `70.0 COP/kWh`
**Precisión**: 2 decimales (float)

### Costo de Energía (Tarifa Total)
**Valor**: `800.0 COP/kWh`
**Precisión**: 2 decimales (float)

---

## Rango de Precios para Consumidores (Enero 2026)

### Precio Mínimo
**Fórmula**:
```
Precio Mínimo = MC_m × 1.1
              = 300.0 × 1.1
              = 330.0 COP/kWh
```

### Precio Máximo
**Fórmula**:
```
Precio Máximo = (Costo Energía - Costo Comercialización) × 0.95
              = (800.0 - 70.0) × 0.95
              = 730.0 × 0.95
              = 693.5 COP/kWh
```

---

## Resumen del Rango

| Concepto | Valor | Unidad |
|----------|-------|--------|
| MC_m (Precio Promedio Contratos) | 300.00 | COP/kWh |
| Costo Comercialización | 70.00 | COP/kWh |
| Costo Energía | 800.00 | COP/kWh |
| **Precio Mínimo Consumidor** | **330.00** | **COP/kWh** |
| **Precio Máximo Consumidor** | **693.50** | **COP/kWh** |

---

## Propósito del Rango

Este rango de precios (330.0 - 693.5 COP/kWh) define el espacio de trabajo para que los consumidores puedan crear ofertas de compra de energía en el sistema P2P, garantizando:

1. **Límite inferior**: Protege a los prosumidores asegurando un precio mínimo de venta (MC_m + 10%)
2. **Límite superior**: Protege a los consumidores evitando precios excesivos (95% del costo neto de energía)

---

## Notas Técnicas

- **Tipo de dato**: `double` (float de 2 decimales)
- **Constantes definidas en**: `lib/data/fake_data_january_2026.dart`
- **Período de aplicación**: Enero 2026 en adelante
- **Regulación**: CREG 101 072 Art 3.4

---

## Actualización de Valores

Si es necesario actualizar estas constantes por mes:

1. Actualizar los valores en `lib/data/fake_data_january_2026.dart`
2. Recalcular automáticamente los rangos mínimo y máximo usando las fórmulas establecidas
3. Actualizar este documento con los nuevos valores
4. Verificar que todas las validaciones en `consumer_offer_service.dart` reflejen los nuevos rangos