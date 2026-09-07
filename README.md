# Taller de Base de Datos — Evaluación Parcial N°1 (BDY1103)

Proyecto: agencia de scouting y reclutamiento de futbolistas, para varios clubes clientes.
Motor: Oracle / PL-SQL.

## Estructura

- `script_carga/Script de Carga.sql` — creación de las 12 tablas (DDL) y poblado de datos (DML),
  ~2.943 filas, en un solo archivo. Debe ejecutarse completo antes que cualquier requerimiento.
- `codigo_fuente/` — scripts de cada requerimiento técnico exigido por la pauta.
  - `Requerimiento 1.sql` — RECORD con campos %TYPE y VARRAY, cargados con BULK COLLECT INTO.
    Genera un reporte de los jugadores mejor evaluados (promedio >= 85).
  - `Requerimiento 2.sql` — cursor explícito con parámetro sobre CLUB, con un segundo cursor
    explícito anidado sobre OFERTA/JUGADOR/CONTRATO. Genera un reporte de negociaciones y
    contratos vigentes/vencidos por club, filtrado por país.
  - `Requerimiento 3.SQL` — manejo de excepciones (predefinidas y personalizada) al registrar
    una evaluación de un jugador.

Los demás archivos del proyecto (informe, presentación, diagrama del modelo) los agrega el
resto del equipo.

## Cómo ejecutar

1. `script_carga/Script de Carga.sql`
2. Cualquiera de los `codigo_fuente/Requerimiento N.sql`, en Oracle SQL Developer.