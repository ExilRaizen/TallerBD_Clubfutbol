SET SERVEROUTPUT ON;

DECLARE
    -- 1. Definición del RECORD con tipos explícitos
    TYPE r_jugador IS RECORD (
        id_jugador    JUGADOR.id_jugador%TYPE,
        nombre        JUGADOR.nombre%TYPE,
        apellido      JUGADOR.apellido%TYPE,
        -- Campo con %TYPE en vez de tipo fijo (VARCHAR2), tal como exige la pauta para el RECORD
        nom_posicion  POSICION.nombre_posicion%TYPE,
        nacionalidad  JUGADOR.nacionalidad%TYPE,
        estado        JUGADOR.estado%TYPE,
        promedio      NUMBER(5,2)
    );
    
    -- 2. Definición del VARRAY
    TYPE t_jugadores IS VARRAY(20) OF r_jugador;
    v_jugadores t_jugadores := t_jugadores();
BEGIN
    -- 3. Carga masiva asegurando que el orden del SELECT coincida exactamente con el RECORD
    SELECT j.id_jugador,
           j.nombre,
           j.apellido,
           p.nombre_posicion,
           j.nacionalidad,
           j.estado,
           AVG((e.puntaje_tecnico + e.puntaje_fisico + e.puntaje_tactico) / 3) AS promedio_general
      BULK COLLECT INTO v_jugadores
      FROM jugador j
      JOIN posicion p ON j.id_posicion = p.id_posicion
      JOIN evaluacion e ON j.id_jugador = e.id_jugador
      GROUP BY j.id_jugador, j.nombre, j.apellido, p.nombre_posicion, j.nacionalidad, j.estado
      HAVING AVG((e.puntaje_tecnico + e.puntaje_fisico + e.puntaje_tactico) / 3) >= 85
      ORDER BY promedio_general DESC
      FETCH FIRST 20 ROWS ONLY;
      
    -- 4. Recorrido del VARRAY para mostrar el reporte
    IF v_jugadores.COUNT > 0 THEN
        FOR i IN 1..v_jugadores.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(i || '. ' || v_jugadores(i).nombre || ' ' || v_jugadores(i).apellido || ' | ' ||
                                'Posicion: ' || v_jugadores(i).nom_posicion || ' | ' || 'Nacionalidad: ' || v_jugadores(i).nacionalidad 
                                || ' | ' || 'Estado: ' || v_jugadores(i).estado);
            DBMS_OUTPUT.PUT_LINE(' - ' || 'Promedio: ' || ROUND(v_jugadores(i).promedio, 2));
            DBMS_OUTPUT.PUT_LINE('=====================================================');
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron jugadores que cumplan con el promedio requerido.');
    END IF;
END;
/