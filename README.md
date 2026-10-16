# Taller de Base de Datos — Evaluación Parcial N°2 (BDY1103)

Proyecto: agencia de scouting y reclutamiento de futbolistas (Football Talent Academy Agency),
para varios clubes clientes.
Motor: Oracle / PL-SQL.

> Esta rama contiene la EP2. La EP1 (RECORD/VARRAY, cursores y excepciones) sigue en `main`.

## Problemática

Las ofertas de los clubes se registran sin controles previos: se ofrecen jugadores con lesiones
graves en recuperación o que ya no están disponibles, se registran ofertas que el club no puede
pagar y se duplican ofertas pendientes. Además, las ofertas que dejaron de ser válidas quedan
pendientes para siempre y no queda registro de quién opera sobre ellas.

La solución aplica 4 reglas de negocio:

1. El jugador debe estar disponible (`DISPONIBLE` o `EN_NEGOCIACION`).
2. El jugador no debe tener una lesión `GRAVE` en recuperación.
3. El club debe tener presupuesto suficiente.
4. No puede existir otra oferta pendiente del mismo club por el mismo jugador.

## Estructura

- `script_carga/Script de Carga.sql` — creación de las tablas (DDL) y poblado de datos (DML).
  Respecto a la EP1 agrega:
  - la tabla `AUDITORIA_OFERTA`, que usa el trigger de sentencia del Requerimiento 4;
  - 4 lesiones `GRAVE` recientes (jugadores 4, 94, 101 y 467), con fecha relativa a `SYSDATE`
    para que sigan activas al ejecutar.
- `codigo_fuente/` — un archivo por requerimiento, con la creación de los objetos y sus pruebas.
  - `Requerimiento 1.SQL` — procedimientos almacenados.
    - `sp_revisar_ofertas_club(p_id_club IN, p_rechazadas OUT)`: revisa con un cursor las ofertas
      pendientes de un club y rechaza las que ya no cumplen las reglas.
    - `sp_revisar_ofertas_pendientes` (sin parámetros): revisa todas las ofertas pendientes,
      llamando al procedimiento anterior por cada club.
  - `Requerimiento 2.SQL` — funciones almacenadas.
    - `fn_lesion_activa(id_jugador)`: 1 si tiene lesión grave activa, 0 si no.
    - `fn_jugador_ofertable(id_jugador)`: 1 si se le puede ofrecer, 0 si no, -1 si no existe.
    - `fn_presupuesto_disponible(id_club)`: presupuesto menos lo comprometido en ofertas
      pendientes; `NULL` si el club no existe.
    - `fn_jugadores_no_ofertables` (sin parámetros): cantidad de jugadores no ofertables.
  - `Requerimiento 3.SQL` — package `pkg_ofertas`.
    - Público: `registrar_oferta`, `revisar_ofertas`, `jugador_ofertable`,
      `presupuesto_disponible` y la variable global `g_ofertas_registradas`.
    - Privado: `oferta_duplicada` y la constante `c_monto_minimo`.
  - `Requerimiento 4.SQL` — triggers sobre `OFERTA`.
    - `trg_oferta_validar` (BEFORE INSERT OR UPDATE, fila).
    - `trg_oferta_no_eliminar` (BEFORE DELETE, sentencia).
    - `trg_oferta_auditoria` (AFTER INSERT OR UPDATE, sentencia).

## Cómo ejecutar

En Oracle SQL Developer, abrir cada archivo y ejecutarlo completo con **F5** (Run Script),
en este orden:

1. `script_carga/Script de Carga.sql`
2. `codigo_fuente/Requerimiento 2.SQL` — funciones (van antes porque los procedimientos las usan)
3. `codigo_fuente/Requerimiento 1.SQL` — procedimientos
4. `codigo_fuente/Requerimiento 3.SQL` — package (usa los objetos de los Req. 1 y 2)
5. `codigo_fuente/Requerimiento 4.SQL` — triggers (usan el package)

Notas:

- La primera vez, los `DROP TABLE` del inicio del script de carga dan error porque las tablas
  no existen. Es normal; lo que importa es que los `CREATE` e `INSERT` se ejecuten bien.
- Las pruebas de cada archivo modifican datos y están pensadas para correr en ese orden, sobre
  una carga limpia. Los resultados esperados están en los comentarios de cada prueba.
- Si se vuelve a ejecutar el script de carga, hay que ejecutar de nuevo los 4 requerimientos:
  el `DROP` de las tablas borra también los triggers.
- Algunas pruebas fallan a propósito (por ejemplo, ofertas de jugadores lesionados o el intento
  de usar un elemento privado del package) para demostrar las validaciones.
