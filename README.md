# Taller de Base de Datos — Evaluación Parcial N°1 (BDY1103)

Proyecto: agencia de scouting y reclutamiento de futbolistas, para varios clubes clientes.
Motor: Oracle / PL-SQL.

## Estructura

- `script_carga/Script de Carga.sql` — creación de las 12 tablas (DDL) y poblado de datos (DML),
  ~2.943 filas, en un solo archivo. Debe ejecutarse completo antes que cualquier requerimiento.
- `codigo_fuente/` — scripts de cada requerimiento técnico exigido por la pauta.
  - `Requerimiento 2.sql` — cursor explícito con parámetro sobre CLUB, con un segundo cursor
    explícito anidado sobre OFERTA/JUGADOR/CONTRATO. Genera un reporte de negociaciones y
    contratos vigentes/vencidos por club, filtrado por país.

Los demás archivos del proyecto (Requerimiento 1, Requerimiento 3, informe, presentación,
diagrama del modelo) los agrega el resto del equipo.

## Cómo ejecutar

1. `script_carga/Script de Carga.sql`
2. Cualquiera de los `codigo_fuente/Requerimiento N.sql`, en Oracle SQL Developer.
