-- =====================================================================
-- REQUERIMIENTO 2: FUNCIONES ALMACENADAS
-- Se ejecuta ANTES que el Requerimiento 1, porque los procedimientos
-- usan estas funciones.
-- =====================================================================

-- ---------------------------------------------------------------------
-- fn_lesion_activa (con parametro)
-- Retorna 1 si el jugador tiene una lesion GRAVE en recuperacion, 0 si no.
-- Una lesion sigue activa mientras fecha_lesion + dias de recuperacion
-- sea mayor a hoy.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_lesion_activa (
    p_id_jugador IN jugador.id_jugador%TYPE
) RETURN NUMBER
IS
    v_cantidad NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_cantidad
      FROM lesion
     WHERE id_jugador = p_id_jugador
       AND gravedad = 'GRAVE'
       AND fecha_lesion + NVL(dias_recuperacion_estimados, 0) > SYSDATE;

    IF v_cantidad > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END fn_lesion_activa;
/

-- ---------------------------------------------------------------------
-- fn_jugador_ofertable (con parametro)
-- Retorna 1 si el jugador puede recibir ofertas (DISPONIBLE o
-- EN_NEGOCIACION y sin lesion grave activa), 0 si no puede
-- y -1 si el jugador no existe.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_jugador_ofertable (
    p_id_jugador IN jugador.id_jugador%TYPE
) RETURN NUMBER
IS
    v_estado jugador.estado%TYPE;
BEGIN
    SELECT estado
      INTO v_estado
      FROM jugador
     WHERE id_jugador = p_id_jugador;

    IF v_estado NOT IN ('DISPONIBLE', 'EN_NEGOCIACION') THEN
        RETURN 0;
    END IF;

    IF fn_lesion_activa(p_id_jugador) = 1 THEN
        RETURN 0;
    END IF;

    RETURN 1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
END fn_jugador_ofertable;
/

-- ---------------------------------------------------------------------
-- fn_presupuesto_disponible (con parametro)
-- Retorna el presupuesto del club menos lo que ya tiene comprometido
-- en ofertas PENDIENTES. Puede ser negativo si el club ofrecio mas de
-- lo que tiene. Si el club no existe retorna NULL.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_presupuesto_disponible (
    p_id_club IN club.id_club%TYPE
) RETURN NUMBER
IS
    v_presupuesto  club.presupuesto%TYPE;
    v_comprometido NUMBER;
BEGIN
    SELECT presupuesto
      INTO v_presupuesto
      FROM club
     WHERE id_club = p_id_club;

    SELECT NVL(SUM(monto_oferta), 0)
      INTO v_comprometido
      FROM oferta
     WHERE id_club = p_id_club
       AND estado_oferta = 'PENDIENTE';

    RETURN v_presupuesto - v_comprometido;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_presupuesto_disponible;
/

-- ---------------------------------------------------------------------
-- fn_jugadores_no_ofertables (sin parametros)
-- Retorna cuantos jugadores de la agencia no pueden recibir ofertas hoy.
-- Usa fn_jugador_ofertable dentro de un SELECT sobre todos los jugadores.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_jugadores_no_ofertables
RETURN NUMBER
IS
    v_cantidad NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_cantidad
      FROM jugador
     WHERE fn_jugador_ofertable(id_jugador) = 0;

    RETURN v_cantidad;
END fn_jugadores_no_ofertables;
/

-- =====================================================================
-- PRUEBAS
-- =====================================================================
SET SERVEROUTPUT ON

-- 1) Funciones dentro de un SELECT sobre muchas filas:
--    jugadores que figuran como disponibles pero tienen una lesion grave activa
--    (resultado esperado: 4, 94, 101 y 467)
SELECT id_jugador,
       nombre || ' ' || apellido      AS jugador,
       estado,
       fn_lesion_activa(id_jugador)    AS lesion_activa,
       fn_jugador_ofertable(id_jugador) AS ofertable
  FROM jugador
 WHERE estado IN ('DISPONIBLE', 'EN_NEGOCIACION')
   AND fn_lesion_activa(id_jugador) = 1
 ORDER BY id_jugador;

-- 2) Presupuesto disponible de los 25 clubes, ordenado de menor a mayor
--    (antes de la revision del Req. 1 varios clubes quedan en negativo,
--    por ejemplo Fenix Metropolitana con -3899167)
SELECT id_club,
       nombre_club,
       presupuesto,
       fn_presupuesto_disponible(id_club) AS disponible
  FROM club
 ORDER BY fn_presupuesto_disponible(id_club);

-- 3) Funcion sin parametros desde SQL (resultado esperado: 306)
SELECT fn_jugadores_no_ofertables AS no_ofertables FROM dual;

-- 4) Funciones desde un bloque anonimo, incluido el caso en que el dato no existe
BEGIN
    DBMS_OUTPUT.PUT_LINE('Jugador 2 ofertable: '    || fn_jugador_ofertable(2));     -- 1
    DBMS_OUTPUT.PUT_LINE('Jugador 4 ofertable: '    || fn_jugador_ofertable(4));     -- 0 (lesion grave)
    DBMS_OUTPUT.PUT_LINE('Jugador 1 ofertable: '    || fn_jugador_ofertable(1));     -- 0 (DESCARTADO)
    DBMS_OUTPUT.PUT_LINE('Jugador 9999 ofertable: ' || fn_jugador_ofertable(9999));  -- -1 (no existe)
    DBMS_OUTPUT.PUT_LINE('Club 999 disponible: '    || NVL(TO_CHAR(fn_presupuesto_disponible(999)), 'NULL (no existe)'));
END;
/
