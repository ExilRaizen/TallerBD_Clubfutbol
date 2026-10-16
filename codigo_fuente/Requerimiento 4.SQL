-- =====================================================================
-- REQUERIMIENTO 4: TRIGGERS SOBRE LA TABLA OFERTA
-- Requiere haber ejecutado antes los Requerimientos 2, 1 y 3.
-- La tabla AUDITORIA_OFERTA se crea en el Script de Carga.
-- =====================================================================

-- ---------------------------------------------------------------------
-- trg_oferta_validar (BEFORE INSERT OR UPDATE, nivel FILA)
-- Ultima barrera: aunque alguien haga un INSERT o UPDATE directo sin
-- pasar por el package, las reglas se cumplen igual.
-- No valida la oferta duplicada porque eso exige consultar OFERTA
-- (tabla mutante); esa regla la cubre pkg_ofertas.registrar_oferta.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_oferta_validar
BEFORE INSERT OR UPDATE OF monto_oferta, estado_oferta ON oferta
FOR EACH ROW
DECLARE
    v_ofertable   NUMBER;
    v_presupuesto club.presupuesto%TYPE;
BEGIN
    -- Una oferta ya ACEPTADA o RECHAZADA no se vuelve a modificar
    IF UPDATING AND :OLD.estado_oferta <> 'PENDIENTE' THEN
        RAISE_APPLICATION_ERROR(-20024, 'La oferta ' || :OLD.id_oferta || ' ya esta '
                                || :OLD.estado_oferta || ' y no puede modificarse.');
    END IF;

    IF INSERTING THEN
        -- Toda oferta nueva nace PENDIENTE
        IF NVL(:NEW.estado_oferta, 'PENDIENTE') <> 'PENDIENTE' THEN
            RAISE_APPLICATION_ERROR(-20020, 'Toda oferta nueva debe registrarse como PENDIENTE.');
        END IF;

        -- Jugador disponible y sin lesion grave: usa la funcion publica del package
        v_ofertable := pkg_ofertas.jugador_ofertable(:NEW.id_jugador);
        IF v_ofertable = -1 THEN
            RAISE_APPLICATION_ERROR(-20025, 'El jugador ' || :NEW.id_jugador || ' no existe.');
        ELSIF v_ofertable = 0 THEN
            IF fn_lesion_activa(:NEW.id_jugador) = 1 THEN
                RAISE_APPLICATION_ERROR(-20022, 'El jugador ' || :NEW.id_jugador || ' tiene una lesion grave en recuperacion.');
            ELSE
                RAISE_APPLICATION_ERROR(-20021, 'El jugador ' || :NEW.id_jugador || ' no esta disponible.');
            END IF;
        END IF;
    END IF;

    -- El club debe poder pagar el monto (se revisa al insertar o al cambiar el monto)
    IF INSERTING OR UPDATING('monto_oferta') THEN
        SELECT presupuesto
          INTO v_presupuesto
          FROM club
         WHERE id_club = :NEW.id_club;

        IF v_presupuesto < :NEW.monto_oferta THEN
            RAISE_APPLICATION_ERROR(-20023, 'El club ' || :NEW.id_club || ' no tiene presupuesto suficiente ('
                                    || v_presupuesto || ' < ' || :NEW.monto_oferta || ').');
        END IF;
    END IF;

    -- Evidencia de cada cambio de estado, fila por fila
    IF UPDATING('estado_oferta') THEN
        DBMS_OUTPUT.PUT_LINE('  [trigger fila] Oferta ' || :OLD.id_oferta || ': '
                             || :OLD.estado_oferta || ' -> ' || :NEW.estado_oferta);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20026, 'El club ' || :NEW.id_club || ' no existe.');
END trg_oferta_validar;
/

-- ---------------------------------------------------------------------
-- trg_oferta_no_eliminar (BEFORE DELETE, nivel SENTENCIA)
-- Las ofertas no se borran: se rechazan, para no perder el historial.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_oferta_no_eliminar
BEFORE DELETE ON oferta
BEGIN
    RAISE_APPLICATION_ERROR(-20030, 'Las ofertas no se eliminan; deben quedar como RECHAZADA para mantener el historial.');
END trg_oferta_no_eliminar;
/

-- ---------------------------------------------------------------------
-- trg_oferta_auditoria (AFTER INSERT OR UPDATE, nivel SENTENCIA)
-- Registra UNA vez cada operacion sobre OFERTA, sin importar cuantas
-- filas haya afectado.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_oferta_auditoria
AFTER INSERT OR UPDATE ON oferta
BEGIN
    IF INSERTING THEN
        INSERT INTO auditoria_oferta (operacion) VALUES ('INSERT');
    ELSIF UPDATING THEN
        INSERT INTO auditoria_oferta (operacion) VALUES ('UPDATE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('  [trigger sentencia] Operacion registrada en AUDITORIA_OFERTA');
END trg_oferta_auditoria;
/

-- =====================================================================
-- PRUEBAS (despues de haber ejecutado las pruebas de los Req. 1 y 3)
-- =====================================================================
SET SERVEROUTPUT ON

-- 1) Oferta valida por el package: Gonzalo Reyes (449) a Sporting Boreal (5)
--    Se disparan ambos triggers y queda 1 INSERT en la auditoria
DECLARE
    v_id oferta.id_oferta%TYPE;
BEGIN
    pkg_ofertas.registrar_oferta(449, 5, 400000, v_id);
END;
/

-- 2) INSERT directo saltandose el package, jugador con lesion grave (-20022)
INSERT INTO oferta (id_jugador, id_club, monto_oferta, estado_oferta)
VALUES (4, 5, 500000, 'PENDIENTE');

-- 3) INSERT directo de jugador DESCARTADO (-20021)
INSERT INTO oferta (id_jugador, id_club, monto_oferta, estado_oferta)
VALUES (1, 5, 500000, 'PENDIENTE');

-- 4) INSERT directo que nace ACEPTADA (-20020)
INSERT INTO oferta (id_jugador, id_club, monto_oferta, estado_oferta)
VALUES (29, 5, 500000, 'ACEPTADA');

-- 5) INSERT directo por sobre el presupuesto total del club 20 (748453) (-20023)
INSERT INTO oferta (id_jugador, id_club, monto_oferta, estado_oferta)
VALUES (29, 20, 900000, 'PENDIENTE');

-- 6) Modificar una oferta ya ACEPTADA (-20024)
UPDATE oferta
   SET estado_oferta = 'RECHAZADA'
 WHERE id_oferta = 2;

-- 7) Fila vs sentencia: un solo UPDATE que rechaza las 3 ofertas pendientes de
--    Sporting del Plata (club 2). El trigger de fila se ejecuta 3 veces y el de
--    sentencia 1 sola vez.
UPDATE oferta
   SET estado_oferta = 'RECHAZADA'
 WHERE id_club = 2
   AND estado_oferta = 'PENDIENTE';
COMMIT;

-- 8) Ejemplo completo: Ignacio Gomez (41) se lesiona durante la negociacion.
--    Al ejecutar la revision del package, su oferta pendiente (121) se rechaza
--    sola y los triggers dejan registro.
INSERT INTO lesion (id_jugador, fecha_lesion, tipo_lesion, gravedad, dias_recuperacion_estimados)
VALUES (41, TRUNC(SYSDATE) - 5, 'Rotura fibrilar', 'GRAVE', 90);
COMMIT;

EXEC pkg_ofertas.revisar_ofertas;

-- 9) Intento de eliminar una oferta (-20030)
DELETE FROM oferta
 WHERE id_oferta = 20;

-- 10) Resultado de la auditoria: se esperan 3 registros
--     (INSERT de la prueba 1, UPDATE de la prueba 7 y UPDATE de la prueba 8).
--     Las operaciones que fallaron no dejan registro.
SELECT * FROM auditoria_oferta ORDER BY id_auditoria;
