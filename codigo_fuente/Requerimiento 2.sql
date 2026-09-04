SET SERVEROUTPUT ON;

-- Requerimiento 2: cursor explicito con parametro sobre CLUB, y un segundo
-- cursor explicito anidado (tambien con parametro) sobre OFERTA/CONTRATO.
-- Requiere haber ejecutado antes el Script de Carga.

DECLARE
    CURSOR c_clubes(p_pais CLUB.pais%TYPE) IS
        SELECT id_club, nombre_club, liga
        FROM CLUB
        WHERE pais = p_pais
        ORDER BY nombre_club;

    CURSOR c_ofertas(p_id_club OFERTA.id_club%TYPE) IS
        SELECT o.id_oferta,
               o.estado_oferta,
               o.monto_oferta,
               j.nombre,
               j.apellido,
               ct.fecha_fin
        FROM OFERTA o
        JOIN JUGADOR j ON j.id_jugador = o.id_jugador
        LEFT JOIN CONTRATO ct ON ct.id_oferta = o.id_oferta
        WHERE o.id_club = p_id_club
        ORDER BY o.fecha_oferta;

    v_pais_buscado    CLUB.pais%TYPE := 'Chile';
    v_estado_contrato VARCHAR2(30);

    v_total_vigentes   NUMBER := 0;
    v_total_vencidos   NUMBER := 0;
    v_total_pendientes NUMBER := 0;
    v_total_rechazadas NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Estado de negociaciones y contratos - Pais: ' || v_pais_buscado || ' ===');

    FOR club_rec IN c_clubes(v_pais_buscado) LOOP
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Club: ' || club_rec.nombre_club || ' (' || club_rec.liga || ')');

        FOR oferta_rec IN c_ofertas(club_rec.id_club) LOOP
            IF oferta_rec.estado_oferta = 'ACEPTADA' THEN
                IF oferta_rec.fecha_fin IS NULL THEN
                    v_estado_contrato := 'SIN CONTRATO REGISTRADO';
                ELSIF oferta_rec.fecha_fin >= SYSDATE THEN
                    v_estado_contrato := 'VIGENTE hasta ' || TO_CHAR(oferta_rec.fecha_fin, 'DD/MM/YYYY');
                    v_total_vigentes := v_total_vigentes + 1;
                ELSE
                    v_estado_contrato := 'VENCIDO desde ' || TO_CHAR(oferta_rec.fecha_fin, 'DD/MM/YYYY');
                    v_total_vencidos := v_total_vencidos + 1;
                END IF;
            ELSIF oferta_rec.estado_oferta = 'PENDIENTE' THEN
                v_estado_contrato := 'OFERTA PENDIENTE';
                v_total_pendientes := v_total_pendientes + 1;
            ELSE
                v_estado_contrato := 'OFERTA RECHAZADA';
                v_total_rechazadas := v_total_rechazadas + 1;
            END IF;

            DBMS_OUTPUT.PUT_LINE('  ' || oferta_rec.nombre || ' ' || oferta_rec.apellido ||
                                  ' | Monto oferta: ' || oferta_rec.monto_oferta ||
                                  ' | ' || v_estado_contrato);
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== Resumen para ' || v_pais_buscado || ' ===');
    DBMS_OUTPUT.PUT_LINE('Contratos vigentes: ' || v_total_vigentes);
    DBMS_OUTPUT.PUT_LINE('Contratos vencidos: ' || v_total_vencidos);
    DBMS_OUTPUT.PUT_LINE('Ofertas pendientes: ' || v_total_pendientes);
    DBMS_OUTPUT.PUT_LINE('Ofertas rechazadas: ' || v_total_rechazadas);
END;
/
