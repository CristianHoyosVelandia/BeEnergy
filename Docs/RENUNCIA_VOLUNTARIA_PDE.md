# Renuncia Voluntaria PDE

## Objetivo

El estado `6 = renuncia_voluntaria` permite que los miembros de una comunidad energetica renuncien parcial o totalmente al PDE que tenian asignado previamente.

El PDE renunciado queda disponible para que otros miembros puedan ofertar por el en el flujo normal de ofertas PDE.

## Concepto Principal

Cada comunidad distribuye su PDE entre sus miembros. La suma comunitaria representa el 100% del PDE disponible.

Ejemplo:

```txt
PDE actual del miembro: 9.99%
Renuncia voluntaria: 4.99%
PDE conservado: 5.00%
PDE liberado para ofertas: 4.99%
```

Ese PDE liberado podra ser ofertado por otros miembros de la comunidad cuando el periodo pase al estado `1 = PDE disponible`.

## Fuente De Verdad Del PDE Vigente

La tabla `community_members` conserva el PDE vigente de cada miembro en el campo:

```sql
community_members.pde_share
```

Las tablas nuevas no reemplazan `community_members`. Sirven para registrar solicitudes de renuncia, auditar cambios, conocer cuanto PDE fue liberado y permitir que otros usuarios oferten por el PDE liberado.

## Flujo General

1. El administrador cambia el periodo PDE a estado `6 = renuncia_voluntaria`.
2. Los usuarios con PDE asignado ven una pantalla de renuncia voluntaria.
3. Cada usuario puede conservar todo su PDE, renunciar una parte sugerida, renunciar una parte manual o renunciar todo su PDE.
4. La solicitud queda registrada en `renuncias_pde`.
5. El administrador revisa las renuncias.
6. Si el administrador acepta una renuncia, se actualiza `community_members.pde_share` y se registra el evento en `logs_renuncias_pde`.
7. Los usuarios que no respondieron conservan su PDE completo.
8. Cuando el administrador cierra el flujo de renuncias, el periodo pasa de estado `6` a estado `1`.
9. En estado `1`, los demas miembros pueden ofertar por el PDE liberado.

## Estado 6

```txt
6 = renuncia_voluntaria
```

Descripcion:

```txt
Periodo en el que los usuarios pueden renunciar parcial o totalmente al PDE previamente asignado.
```

## Diferencia Con Estado 1

Estado `1 = PDE disponible`:

- Los usuarios ofertan por PDE disponible.
- Es el flujo normal de ofertas.

Estado `6 = renuncia_voluntaria`:

- Los usuarios con PDE asignado deciden si liberan parte de su PDE.
- El PDE liberado todavia no se oferta.
- El admin debe cerrar el flujo.
- Luego el periodo pasa a estado `1`.

## Reglas De Negocio

### Usuario Que No Responde

Si un usuario no responde durante el estado `6`, conserva su PDE completo.

No se modifica su registro en `community_members`.

### Renuncia Parcial

Si un usuario tiene:

```txt
pde_share = 0.0999
```

Y renuncia:

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

### Renuncia Total

Si un usuario renuncia todo su PDE:

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

El usuario no puede renunciar mas PDE del que tiene asignado.

```txt
pde_renunciado <= pde_original
```

El PDE conservado no puede ser negativo.

```txt
pde_conservado >= 0
```

El PDE liberado sera la suma de renuncias aceptadas.

```txt
PDE liberado = SUM(renuncias_pde.pde_renunciado WHERE estado = 'aceptada')
```

## Estados De Renuncia

La tabla `renuncias_pde.estado` usa `VARCHAR`.

Estados propuestos:

```txt
pendiente
aceptada
rechazada
cancelada
cerrada
```

## Acciones Auditables

Cada evento importante debe guardarse en `logs_renuncias_pde`.

Acciones propuestas:

```txt
renuncia_creada
renuncia_actualizada
renuncia_aceptada
renuncia_rechazada
renuncia_cancelada
pde_miembro_actualizado
flujo_renuncias_cerrado
estado_periodo_cambiado
oferta_creada
oferta_aceptada
oferta_rechazada
oferta_cancelada
```

## Pantalla Frontend Estado 6

La pantalla debe mostrar:

- PDE actual del usuario.
- Consumo del periodo.
- Sugerencia de renuncia.
- PDE que conservaria.
- PDE que liberaria.

Acciones:

- Conservar todo.
- Renunciar sugerido.
- Renunciar manualmente.
- Renunciar todo.

## Cierre Administrativo

El administrador debe ver:

- Miembros con PDE asignado.
- Miembros que respondieron.
- Miembros que no respondieron.
- Renuncias pendientes.
- Renuncias aceptadas.
- PDE total liberado.

Al cerrar el flujo:

```txt
pde_period.status_code = 1
```

Los usuarios que no respondieron conservan su `community_members.pde_share`.
