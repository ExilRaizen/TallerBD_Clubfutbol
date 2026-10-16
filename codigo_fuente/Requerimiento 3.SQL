-- =====================================================================
-- REQUERIMIENTO 3: PACKAGE pkg_ofertas
-- Requiere haber ejecutado antes los Requerimientos 2 y 1.
-- Agrupa en un solo punto todo lo que la agencia necesita para
-- gestionar ofertas.
-- =====================================================================

-- ---------------------------------------------------------------------
-- ESPECIFICACION: lo PUBLICO
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_ofertas IS

    -- Variable global: ofertas registradas en la sesion
    g_ofertas_registradas NUMBER := 0;

    -- Consultas que usan otras areas, SELECT y el trigger del Req. 4
    FUNCTION jugador_ofertable (
        p_id_jugador jugador.id_jugador%TYPE
    ) RETURN NUMBER;

    FUNCTION presupuesto_disponible (
        p_id_club club.id_club%TYPE
    ) RETURN NUMBER;

    -- Registra una oferta solo si cumple las 4 reglas de negocio
    PROCEDURE registrar_oferta (
        p_id_jugador IN  oferta.id_jugador%TYPE,
        p_id_club    IN  oferta.id_club%TYPE,
        p_monto      IN  oferta.monto_oferta%TYPE,
        p_id_oferta  OUT oferta.id_oferta%TYPE
    );

    -- Revision masiva de todas las ofertas pendientes
    PROCEDURE revisar_ofertas;

END pkg_ofertas;
/

-- ---------------------------------------------------------------------
-- CUERPO: el codigo de lo publico + lo PRIVADO
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_ofertas IS

    -- PRIVADO: monto minimo para que una oferta sea seria
    c_monto_minimo CONSTANT NUMBER := 50000;

    -- PRIVADO: TRUE si el club ya tiene una oferta pendiente por el jugador.
    -- Consulta la tabla OFERTA, por eso no puede usarla el trigger de fila
    -- sobre OFERTA (tabla mutante) y queda solo para uso interno.
    FUNCTION oferta_duplicada (
        p_id_jugador oferta.id_jugador%TYPE,
        p_id_club    oferta.id_club%TYPE
    ) RETURN BOOLEAN
    IS
        v_cantidad NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_cantidad
          FROM oferta
         WHERE id_jugador = p_id_jugador
           AND id_club = p_id_club
           AND estado_oferta = 'PENDIENTE';

        RETURN v_cantidad > 0;
    END oferta_duplicada;

    -- PUBLICO: reutiliza la funcion del Req. 2
    FUNCTION jugador_ofertable (
        p_id_jugador jugador.id_jugador%TYPE
    ) RETURN NUMBER
    IS
    BEGIN
        RETURN fn_jugador_ofertable(p_id_jugador);
    END jugador_ofertable;

    -- PUBLICO: reutiliza la funcion del Req. 2
    FUNCTION presupuesto_disponible (
        p_id_club club.id_club%TYPE
    ) RETURN NUMBER
    IS
    BEGIN
        RETURN fn_presupuesto_disponible(p_id_club);
    END presupuesto_disponible;

    -- PUBLICO: valida las reglas de negocio y registra la oferta
    PROCEDURE registrar_oferta (
        p_id_jugador IN  oferta.id_jugador%TYPE,
        p_id_club    IN  oferta.id_club%TYPE,
        p_monto      IN  oferta.monto_oferta%TYPE,
        p_id_oferta  OUT oferta.id_oferta%TYPE
    ) IS
        v_ofertable  NUMBER;
        v_disponible NUMBER;
    BEGIN
        p_id_oferta := NULL;

        IF p_monto IS NULL OR p_monto < c_monto_minimo THEN
            RAISE_APPLICATION_ERROR(-20101, 'El monto minimo de una oferta es ' || c_monto_minimo || '.');
        END IF;

        -- Reglas 1 y 2: jugador disponible y sin lesion grave
        v_ofertable := jugador_ofertable(p_id_jugador);
        IF v_ofertable = -1 THEN
            RAISE_APPLICATION_ERROR(-20102, 'El jugador ' || p_id_jugador || ' no existe.');
        ELSIF v_ofertable = 0 THEN
            RAISE_APPLICATION_ERROR(-20103, 'El jugador ' || p_id_jugador || ' no esta disponible o tiene una lesion grave en recuperacion.');
        END IF;

        -- Regla 3: presupuesto disponible del club
        v_disponible := presupuesto_disponible(p_id_club);
        IF v_disponible IS NULL THEN
            RAISE_APPLICATION_ERROR(-20104, 'El club ' || p_id_club || ' no existe.');
        ELSIF v_disponible < p_monto THEN
            RAISE_APPLICATION_ERROR(-20105, 'El club ' || p_id_club || ' solo tiene ' || v_disponible || ' disponible.');
        END IF;

        -- Regla 4: sin oferta pendiente duplicada (funcion privada)
        IF oferta_duplicada(p_id_jugador, p_id_club) THEN
            RAISE_APPLICATION_ERROR(-20106, 'El club ' || p_id_club || ' ya tiene una oferta pendiente por el jugador ' || p_id_jugador || '.');
        END IF;

        INSERT INTO oferta (id_jugador, id_club, fecha_oferta, monto_oferta, estado_oferta)
        VALUES (p_id_jugador, p_id_club, SYSDATE, p_monto, 'PENDIENTE')
        RETURNING id_oferta INTO p_id_oferta;

        UPDATE jugador
           SET estado = 'EN_NEGOCIACION'
         WHERE id_jugador = p_id_jugador
           AND estado = 'DISPONIBLE';

        COMMIT;
        g_ofertas_registradas := g_ofertas_registradas + 1;

        DBMS_OUTPUT.PUT_LINE('Oferta ' || p_id_oferta || ' registrada: jugador ' || p_id_jugador
                             || ', club ' || p_id_club || ', monto ' || p_monto);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_id_oferta := NULL;
            DBMS_OUTPUT.PUT_LINE('Oferta no registrada: ' || SQLERRM);
    END registrar_oferta;

    -- PUBLICO: reutiliza el procedimiento sin parametros del Req. 1
    PROCEDURE revisar_ofertas
    IS
    BEGIN
        sp_revisar_ofertas_pendientes;
    END revisar_ofertas;

END pkg_ofertas;
/

-- =====================================================================
-- PRUEBAS (despues de haber ejecutado las pruebas del Req. 1)
-- =====================================================================
SET SERVEROUTPUT ON

-- 1) Oferta valida: Matias Munoz (2) a Sport Club Boreal (25)
--    Se espera la oferta 201 y el jugador pasa a EN_NEGOCIACION
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(2, 25, 500000, v_id);
    DBMS_OUTPUT.PUT_LINE('Id recibido por el OUT: ' || v_id);
END;
/

-- 2) Duplicada: el mismo club vuelve a ofertar por el mismo jugador (-20106)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(2, 25, 600000, v_id);
END;
/

-- 3) Jugador con lesion grave: Bautista Nunez (4) (-20103)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(4, 25, 500000, v_id);
END;
/

-- 4) Jugador DESCARTADO: Ignacio Paz (1) (-20103)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(1, 25, 500000, v_id);
END;
/

-- 5) Sin presupuesto disponible: Alianza del Plata (24) solo tiene 30125 libres (-20105)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(29, 24, 100000, v_id);
END;
/

-- 6) Monto bajo el minimo privado (-20101)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(29, 25, 10000, v_id);
END;
/

-- 7) Jugador y club que no existen (-20102 y -20104)
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(9999, 25, 500000, v_id);
    pkg_ofertas.registrar_oferta(29, 999, 500000, v_id);
END;
/

-- 8) Funcion publica del package dentro de un SELECT
SELECT id_club,
       nombre_club,
       pkg_ofertas.presupuesto_disponible(id_club) AS disponible
  FROM club
 ORDER BY id_club;

-- 9) Variable global del package (se espera 1)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ofertas registradas en la sesion: ' || pkg_ofertas.g_ofertas_registradas);
END;
/

-- 10) Intento de usar un elemento privado desde afuera.
--     Da error PLS-00302 al compilar el bloque: oferta_duplicada no existe fuera del package.
BEGIN
    IF pkg_ofertas.oferta_duplicada(2, 25) THEN
        DBMS_OUTPUT.PUT_LINE('Duplicada');
    END IF;
END;
/
