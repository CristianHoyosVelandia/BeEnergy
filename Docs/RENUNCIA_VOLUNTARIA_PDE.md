# Ciclo PDE: Cobro y Aporte Comunitario

## Objetivo

La maquina de estados PDE representa el ciclo comunitario completo entre un periodo historico y la apertura de un nuevo periodo de ofertas.

El flujo operativo queda definido asi:

```txt
5 Historico -> 7 Cobro -> 6 Aporte comunitario -> 1 PDE Disponible -> 2 Periodo Cerrado -> 3 Ofertas Finalizadas -> 4 En Conciliacion -> 5 Historico
```

## Estados

| Codigo | Estado | Descripcion operativa |
| --- | --- | --- |
| 1 | PDE Disponible | Periodo abierto para crear ofertas PDE. |
| 2 | Periodo Cerrado | No se aceptan nuevas ofertas y se prepara la liquidacion. |
| 3 | Ofertas Finalizadas | Ofertas procesadas, adjudicadas y liquidadas. |
| 4 | En Conciliacion | Validacion con comercializador. |
| 5 | Historico | Periodo archivado para consulta. |
| 6 | Aporte comunitario | Usuarios pueden aportar o ceder PDE previamente asignado a la bolsa comunitaria. |
| 7 | Cobro | Cobro de la liquidacion del mes anterior. |

## Estado 7: Cobro

El estado `7 = Cobro` representa el cobro por liquidacion del mes anterior.

Reglas objetivo:

- El usuario debe pagar dentro de la app cuando exista pasarela.
- Mientras no exista pasarela, el frontend simula el pago visualmente.
- Usuarios que paguen quedan habilitados para el siguiente ciclo PDE.
- Usuarios que no paguen quedan excluidos temporalmente del proximo periodo PDE.
- El PDE o excedente del usuario no pagado retorna a la bolsa comunitaria como una renuncia total temporal.
- Si el usuario paga posteriormente, se le puede restaurar el PDE anterior.

En esta fase solo se implementa la vista mock. La persistencia real de cobros queda para una fase posterior.

## Estado 6: Aporte Comunitario

El estado `6 = Aporte comunitario` permite que los miembros de una comunidad energetica aporten parcial o totalmente el PDE que tenian asignado previamente.

El PDE aportado queda disponible para que otros miembros puedan ofertar por el en el flujo normal de ofertas PDE.

Ejemplo:

```txt
PDE actual del miembro: 9.99%
Aporte comunitario: 4.99%
PDE conservado: 5.00%
PDE liberado para ofertas: 4.99%
```

## Fuente De Verdad Del PDE Vigente

La tabla `community_members` conserva el PDE vigente de cada miembro en el campo:

```sql
community_members.pde_share
```

Las tablas de renuncia/aporte no reemplazan `community_members`. Sirven para registrar solicitudes, auditar cambios, conocer cuanto PDE fue liberado y permitir que otros usuarios oferten por el PDE liberado.

## Flujo General De Aporte

1. El periodo llega a estado `6 = Aporte comunitario`.
2. Los usuarios con PDE asignado ven una pantalla de aporte PDE.
3. Cada usuario puede conservar todo su PDE, aportar una parte sugerida, aportar una parte manual o aportar todo su PDE.
4. La solicitud queda registrada en `renuncias_pde`.
5. El administrador revisa las solicitudes.
6. Si el administrador acepta un aporte, se actualiza `community_members.pde_share` y se registra el evento en `logs_renuncias_pde`.
7. Los usuarios que no respondieron conservan su PDE completo.
8. Cuando el administrador cierra el flujo de aportes, el periodo pasa de estado `6` a estado `1`.
9. En estado `1`, los demas miembros pueden ofertar por el PDE liberado.

## Reglas De Negocio

### Usuario Que No Responde

Si un usuario no responde durante el estado `6`, conserva su PDE completo.

No se modifica su registro en `community_members`.

### Aporte Parcial

Si un usuario tiene:

```txt
pde_share = 0.0999
```

Y aporta:

```txt
pde_renunciado = 0.0499
```

Entonces conserva:

```txt
pde_conservado = 0.0500
```

Cuando el admin acepta:

```sql
UPDATE community_members
SET pde_share = 0.0500
WHERE community_id = ?
  AND user_id = ?;
```

### Aporte Total

Si un usuario aporta todo su PDE:

```txt
pde_original = 0.0999
pde_renunciado = 0.0999
pde_conservado = 0.0000
```

Cuando el admin acepta:

```txt
community_members.pde_share = 0.0000
```

### Limites

El usuario no puede aportar mas PDE del que tiene asignado.

```txt
pde_renunciado <= pde_original
```

El PDE conservado no puede ser negativo.

```txt
pde_conservado >= 0
```

El PDE liberado sera la suma de aportes aceptados.

```txt
PDE liberado = SUM(renuncias_pde.pde_renunciado WHERE estado = 'aceptada')
```

## Persistencia Futura De Cobros

Cuando se implemente la pasarela y el cron real, se deben crear tablas para:

- `cobros_pde`
- `logs_cobros_pde`
- exclusiones temporales PDE

El cron mensual debera:

- identificar usuarios pagados
- identificar usuarios no pagados
- excluir temporalmente usuarios no pagados del siguiente periodo PDE
- retornar su PDE/excedente a la bolsa comunitaria
- restaurar PDE anterior cuando el usuario pague posteriormente
