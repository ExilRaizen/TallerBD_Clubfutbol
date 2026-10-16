-- =====================================================================
-- REQUERIMIENTO 1: PROCEDIMIENTOS ALMACENADOS
-- Requiere haber ejecutado antes el Requerimiento 2 (funciones).
-- =====================================================================

-- ---------------------------------------------------------------------
-- sp_revisar_ofertas_club (con parametros)
--   p_id_club    IN  : club a revisar
--   p_rechazadas OUT : cuantas ofertas se rechazaron
-- Recorre las ofertas PENDIENTES del club, de la mas antigua a la mas
-- nueva, y rechaza las que ya no cumplen las reglas:
--   - el jugador ya no se puede ofrecer (fichado, descartado o lesionado)
--   - el club no alcanza a pagarla con el presupuesto que le queda
-- El presupuesto se va reservando por orden de llegada de las ofertas.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_revisar_ofertas_club (
    p_id_club    IN  club.id_club%TYPE,
    p_rechazadas OUT NUMBER
) IS
    CURSOR c_ofertas IS
        SELECT o.id_oferta,
               o.id_jugador,
               o.monto_oferta,
               j.nombre || ' ' || j.apellido AS jugador
          FROM oferta o
          JOIN jugador j ON j.id_jugador = o.id_jugador
         WHERE o.id_club = p_id_club
           AND o.estado_oferta = 'PENDIENTE'
         ORDER BY o.fecha_oferta, o.id_oferta;

    v_nombre_club club.nombre_club%TYPE;
    v_disponible  club.presupuesto%TYPE;
    v_motivo      VARCHAR2(40);
BEGIN
    p_rechazadas := 0;

    SELECT nombre_club, presupuesto
      INTO v_nombre_club, v_disponible
      FROM club
     WHERE id_club = p_id_club;

    FOR r IN c_ofertas LOOP
        v_motivo := NULL;

        IF fn_jugador_ofertable(r.id_jugador) <> 1 THEN
            IF fn_lesion_activa(r.id_jugador) = 1 THEN
                v_motivo := 'jugador con lesion grave';
            ELSE
                v_motivo := 'jugador no disponible';
            END IF;
        ELSIF r.monto_oferta > v_disponible THEN
            v_motivo := 'presupuesto insuficiente';
        ELSE
            v_disponible := v_disponible - r.monto_oferta;
        END IF;

        IF v_motivo IS NOT NULL THEN
            UPDATE oferta
               SET estado_oferta = 'RECHAZADA'
             WHERE id_oferta = r.id_oferta;

            p_rechazadas := p_rechazadas + 1;
            DBMS_OUTPUT.PUT_LINE('  Oferta ' || r.id_oferta || ' (' || r.jugador || ') rechazada: ' || v_motivo);
        END IF;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE(v_nombre_club || ' (club ' || p_id_club || '): ' || p_rechazadas || ' ofertas rechazadas');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El club ' || p_id_club || ' no existe.');
END sp_revisar_ofertas_club;
/

-- ---------------------------------------------------------------------
-- sp_revisar_ofertas_pendientes (sin parametros)
-- Revisa TODAS las ofertas pendientes de la agencia: recorre cada club
-- que tenga ofertas pendientes y llama a sp_revisar_ofertas_club.
-- Al final muestra un resumen del proceso.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_revisar_ofertas_pendientes
IS
    CURSOR c_clubes IS
        SELECT c.id_club
          FROM club c
         WHERE EXISTS (SELECT 1
                         FROM oferta o
                        WHERE o.id_club = c.id_club
                          AND o.estado_oferta = 'PENDIENTE')
         ORDER BY c.id_club;

    v_revisadas       NUMBER;
    v_rechazadas_club NUMBER;
    v_total_rechazadas NUMBER := 0;
BEGIN
    SELECT COUNT(*)
      INTO v_revisadas
      FROM oferta
     WHERE estado_oferta = 'PENDIENTE';

    DBMS_OUTPUT.PUT_LINE('=== Revision de ofertas pendientes ===');

    FOR r IN c_clubes LOOP
        sp_revisar_ofertas_club(r.id_club, v_rechazadas_club);
        v_total_rechazadas := v_total_rechazadas + v_rechazadas_club;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Ofertas revisadas: '   || v_revisadas);
    DBMS_OUTPUT.PUT_LINE('Ofertas rechazadas: '  || v_total_rechazadas);
    DBMS_OUTPUT.PUT_LINE('Ofertas que siguen vigentes: ' || (v_revisadas - v_total_rechazadas));
    DBMS_OUTPUT.PUT_LINE('Jugadores que hoy no se pueden ofrecer: ' || fn_jugadores_no_ofertables);
END sp_revisar_ofertas_pendientes;
/

-- =====================================================================
-- PRUEBAS
-- =====================================================================
SET SERVEROUTPUT ON

-- Estado de las ofertas antes de la revision (PENDIENTE 80)
SELECT estado_oferta, COUNT(*) AS cantidad
  FROM oferta
 GROUP BY estado_oferta;

-- 1) Procedimiento con parametros, invocado desde un bloque anonimo.
--    Fenix Metropolitana (club 20): se esperan 5 rechazadas
--    (4 por jugador no disponible y 1 por presupuesto insuficiente)
DECLARE
    v_rechazadas NUMBER;
BEGIN
    sp_revisar_ofertas_club(20, v_rechazadas);
    DBMS_OUTPUT.PUT_LINE('Valor recibido por el OUT: ' || v_rechazadas);
END;
/

-- 2) Club que no existe
DECLARE
    v_rechazadas NUMBER;
BEGIN
    sp_revisar_ofertas_club(999, v_rechazadas);
END;
/

-- 3) Procedimiento sin parametros: revision completa
--    Se esperan 75 revisadas, 48 rechazadas, 27 vigentes y 306 jugadores no ofertables
EXEC sp_revisar_ofertas_pendientes;

-- Estado de las ofertas despues de la revision (PENDIENTE 27)
SELECT estado_oferta, COUNT(*) AS cantidad
  FROM oferta
 GROUP BY estado_oferta;

-- Despues de la revision ningun club queda con presupuesto disponible negativo
SELECT id_club, nombre_club, fn_presupuesto_disponible(id_club) AS disponible
  FROM club
 ORDER BY fn_presupuesto_disponible(id_club);
