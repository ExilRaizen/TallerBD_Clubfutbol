--2
CREATE OR REPLACE PROCEDURE sp_registrar_evaluacion (
    p_id_jugador      IN JUGADOR.id_jugador%TYPE,
    p_id_scout        IN SCOUT.id_scout%TYPE,
    p_puntaje_tecnico IN NUMBER,
    p_puntaje_fisico  IN NUMBER,
    p_puntaje_tactico IN NUMBER
) AS
    -- Variables locales
    v_estado_jugador JUGADOR.estado%TYPE;
    v_nombre_scout   SCOUT.nombre%TYPE;
    v_promedio       NUMBER(5, 2);

    -- Declaración de Excepción Personalizada (Regla de Negocio)
    e_estado_invalido EXCEPTION;

BEGIN
    -- 1. Validar existencia del Scout (Dispara NO_DATA_FOUND si no existe)
    SELECT nombre 
    INTO v_nombre_scout
    FROM SCOUT
    WHERE id_scout = p_id_scout;

    -- 2. Validar existencia del Jugador (Dispara NO_DATA_FOUND si no existe)
    SELECT estado 
    INTO v_estado_jugador
    FROM JUGADOR
    WHERE id_jugador = p_id_jugador;

    -- 3. Validar regla de negocio (Excepción Personalizada)
    IF v_estado_jugador IN ('DESCARTADO', 'FICHADO') THEN
        RAISE e_estado_invalido;
    END IF;

    -- 4. Validar rango de notas (Forzado a VALUE_ERROR si están fuera del rango 0-100)
    IF p_puntaje_tecnico NOT BETWEEN 0 AND 100 OR
       p_puntaje_fisico  NOT BETWEEN 0 AND 100 OR
       p_puntaje_tactico NOT BETWEEN 0 AND 100 THEN
        RAISE VALUE_ERROR;
    END IF;

    -- 5. Cálculo del promedio
    v_promedio := (p_puntaje_tecnico + p_puntaje_fisico + p_puntaje_tactico) / 3;

    -- 6. Actualización según rendimiento
    IF v_promedio >= 70 THEN
        UPDATE JUGADOR
        SET estado = 'EN_NEGOCIACION'
        WHERE id_jugador = p_id_jugador;
    ELSE
        UPDATE JUGADOR
        SET estado = 'DESCARTADO'
        WHERE id_jugador = p_id_jugador;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Evaluación registrada con éxito.');
    DBMS_OUTPUT.PUT_LINE('Jugador ID: ' || p_id_jugador || ' | Evaluador: ' || v_nombre_scout);
    DBMS_OUTPUT.PUT_LINE('Promedio: ' || TO_CHAR(v_promedio, '990.00') || ' | Nuevo Estado: ' || 
                         CASE WHEN v_promedio >= 70 THEN 'EN_NEGOCIACION' ELSE 'DESCARTADO' END);

EXCEPTION
    -- Excepción Predefinida 1: Clave primaria inexistente
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR [NO_DATA_FOUND]: El ID del jugador (' || p_id_jugador || 
                             ') o del Scout (' || p_id_scout || ') no existe en la base de datos.');

    -- Excepción Predefinida 2: Incompatibilidad o desbordamiento de tipos/datos
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('ERROR [VALUE_ERROR]: Los puntajes ingresados deben estar entre 0 y 100 y tener un formato numérico válido.');

    -- Excepción Personalizada de Usuario: Control de estado del jugador
    WHEN e_estado_invalido THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR DE NEGOCIO: No se permite evaluar a un jugador en estado ' || v_estado_jugador || '.');

    -- Captura de cualquier otro error no especificado
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END sp_registrar_evaluacion;
/

--1
SET SERVEROUTPUT ON;
--3
--Evaluacion exitosa
BEGIN
    sp_registrar_evaluacion(
        p_id_jugador      => 4, 
        p_id_scout        => 10, 
        p_puntaje_tecnico => 85, 
        p_puntaje_fisico  => 78, 
        p_puntaje_tactico => 90
    );
END;
/
--4
--Error no_data_found
BEGIN
    sp_registrar_evaluacion(
        p_id_jugador      => 9999, 
        p_id_scout        => 10, 
        p_puntaje_tecnico => 80, 
        p_puntaje_fisico  => 80, 
        p_puntaje_tactico => 80
    );
END;
/
--5
--error value_Error
BEGIN
    sp_registrar_evaluacion(
        p_id_jugador      => 6, 
        p_id_scout        => 10, 
        p_puntaje_tecnico => 150, 
        p_puntaje_fisico  => 80, 
        p_puntaje_tactico => 80
    );
END;
/
--6
--Excepcion personalizada 
BEGIN
    sp_registrar_evaluacion(
        p_id_jugador      => 1, 
        p_id_scout        => 10, 
        p_puntaje_tecnico => 85, 
        p_puntaje_fisico  => 85, 
        p_puntaje_tactico => 85
    );
END;
/