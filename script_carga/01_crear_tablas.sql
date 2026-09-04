DROP TABLE COMISION CASCADE CONSTRAINTS;
DROP TABLE HISTORIAL_CLUB CASCADE CONSTRAINTS;
DROP TABLE LESION CASCADE CONSTRAINTS;
DROP TABLE CONTRATO CASCADE CONSTRAINTS;
DROP TABLE OFERTA CASCADE CONSTRAINTS;
DROP TABLE PARTICIPACION_PRUEBA CASCADE CONSTRAINTS;
DROP TABLE PRUEBA CASCADE CONSTRAINTS;
DROP TABLE EVALUACION CASCADE CONSTRAINTS;
DROP TABLE JUGADOR CASCADE CONSTRAINTS;
DROP TABLE SCOUT CASCADE CONSTRAINTS;
DROP TABLE CLUB CASCADE CONSTRAINTS;
DROP TABLE POSICION CASCADE CONSTRAINTS;

CREATE TABLE POSICION (
    id_posicion      NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
    nombre_posicion  VARCHAR2(30) NOT NULL,
    CONSTRAINT pk_posicion       PRIMARY KEY (id_posicion),
    CONSTRAINT uq_posicion_nombre UNIQUE (nombre_posicion)
);

CREATE TABLE CLUB (
    id_club          NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre_club      VARCHAR2(60) NOT NULL,
    pais             VARCHAR2(40) NOT NULL,
    liga             VARCHAR2(60),
    presupuesto      NUMBER(12,2) DEFAULT 0,
    contacto_nombre  VARCHAR2(60),
    contacto_email   VARCHAR2(80),
    CONSTRAINT pk_club PRIMARY KEY (id_club),
    CONSTRAINT ck_club_presupuesto CHECK (presupuesto >= 0)
);

CREATE TABLE SCOUT (
    id_scout          NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre            VARCHAR2(40) NOT NULL,
    apellido          VARCHAR2(40) NOT NULL,
    region_cobertura  VARCHAR2(60),
    telefono          VARCHAR2(20),
    email             VARCHAR2(80),
    CONSTRAINT pk_scout    PRIMARY KEY (id_scout),
    CONSTRAINT uq_scout_email UNIQUE (email)
);

CREATE TABLE JUGADOR (
    id_jugador        NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre            VARCHAR2(40) NOT NULL,
    apellido          VARCHAR2(40) NOT NULL,
    fecha_nacimiento  DATE NOT NULL,
    nacionalidad      VARCHAR2(40) NOT NULL,
    id_posicion       NUMBER NOT NULL,
    pie_habil         VARCHAR2(12) DEFAULT 'DERECHO',
    altura_cm         NUMBER(3),
    peso_kg           NUMBER(5,2),
    club_origen       VARCHAR2(60),
    estado            VARCHAR2(20) DEFAULT 'DISPONIBLE',
    CONSTRAINT pk_jugador PRIMARY KEY (id_jugador),
    CONSTRAINT fk_jugador_posicion FOREIGN KEY (id_posicion) REFERENCES POSICION(id_posicion),
    CONSTRAINT ck_jugador_pie      CHECK (pie_habil IN ('IZQUIERDO','DERECHO','AMBIDIESTRO')),
    CONSTRAINT ck_jugador_estado   CHECK (estado IN ('DISPONIBLE','EN_NEGOCIACION','FICHADO','DESCARTADO')),
    CONSTRAINT ck_jugador_altura   CHECK (altura_cm BETWEEN 140 AND 220),
    CONSTRAINT ck_jugador_peso     CHECK (peso_kg BETWEEN 40 AND 150)
);

CREATE TABLE EVALUACION (
    id_evaluacion     NUMBER GENERATED ALWAYS AS IDENTITY,
    id_jugador        NUMBER NOT NULL,
    id_scout          NUMBER NOT NULL,
    fecha_evaluacion  DATE DEFAULT SYSDATE NOT NULL,
    puntaje_tecnico   NUMBER(3),
    puntaje_fisico    NUMBER(3),
    puntaje_tactico   NUMBER(3),
    observaciones     VARCHAR2(500),
    CONSTRAINT pk_evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT fk_evaluacion_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT fk_evaluacion_scout   FOREIGN KEY (id_scout)   REFERENCES SCOUT(id_scout),
    CONSTRAINT ck_evaluacion_tecnico CHECK (puntaje_tecnico BETWEEN 0 AND 100),
    CONSTRAINT ck_evaluacion_fisico  CHECK (puntaje_fisico  BETWEEN 0 AND 100),
    CONSTRAINT ck_evaluacion_tactico CHECK (puntaje_tactico BETWEEN 0 AND 100)
);

CREATE TABLE PRUEBA (
    id_prueba      NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre_prueba  VARCHAR2(80) NOT NULL,
    fecha_prueba   DATE NOT NULL,
    ubicacion      VARCHAR2(80),
    categoria      VARCHAR2(20),
    CONSTRAINT pk_prueba PRIMARY KEY (id_prueba)
);

CREATE TABLE PARTICIPACION_PRUEBA (
    id_participacion  NUMBER GENERATED ALWAYS AS IDENTITY,
    id_jugador        NUMBER NOT NULL,
    id_prueba         NUMBER NOT NULL,
    resultado         VARCHAR2(20) DEFAULT 'EN_EVALUACION',
    puntaje_obtenido  NUMBER(3),
    CONSTRAINT pk_participacion PRIMARY KEY (id_participacion),
    CONSTRAINT fk_participacion_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT fk_participacion_prueba  FOREIGN KEY (id_prueba)  REFERENCES PRUEBA(id_prueba),
    CONSTRAINT uq_participacion UNIQUE (id_jugador, id_prueba),
    CONSTRAINT ck_participacion_resultado CHECK (resultado IN ('APTO','NO_APTO','EN_EVALUACION')),
    CONSTRAINT ck_participacion_puntaje   CHECK (puntaje_obtenido BETWEEN 0 AND 100)
);

CREATE TABLE OFERTA (
    id_oferta      NUMBER GENERATED ALWAYS AS IDENTITY,
    id_jugador     NUMBER NOT NULL,
    id_club        NUMBER NOT NULL,
    fecha_oferta   DATE DEFAULT SYSDATE NOT NULL,
    monto_oferta   NUMBER(12,2) NOT NULL,
    estado_oferta  VARCHAR2(20) DEFAULT 'PENDIENTE',
    CONSTRAINT pk_oferta PRIMARY KEY (id_oferta),
    CONSTRAINT fk_oferta_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT fk_oferta_club    FOREIGN KEY (id_club)    REFERENCES CLUB(id_club),
    CONSTRAINT ck_oferta_estado  CHECK (estado_oferta IN ('PENDIENTE','ACEPTADA','RECHAZADA')),
    CONSTRAINT ck_oferta_monto   CHECK (monto_oferta > 0)
);

CREATE TABLE CONTRATO (
    id_contrato         NUMBER GENERATED ALWAYS AS IDENTITY,
    id_oferta           NUMBER NOT NULL,
    id_jugador          NUMBER NOT NULL,
    id_club             NUMBER NOT NULL,
    fecha_inicio        DATE NOT NULL,
    fecha_fin           DATE NOT NULL,
    salario_mensual     NUMBER(12,2) NOT NULL,
    clausula_rescision  NUMBER(14,2),
    CONSTRAINT pk_contrato PRIMARY KEY (id_contrato),
    CONSTRAINT fk_contrato_oferta  FOREIGN KEY (id_oferta)  REFERENCES OFERTA(id_oferta),
    CONSTRAINT fk_contrato_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT fk_contrato_club    FOREIGN KEY (id_club)    REFERENCES CLUB(id_club),
    CONSTRAINT uq_contrato_oferta  UNIQUE (id_oferta),
    CONSTRAINT ck_contrato_fechas  CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT ck_contrato_salario CHECK (salario_mensual > 0)
);

CREATE TABLE LESION (
    id_lesion                    NUMBER GENERATED ALWAYS AS IDENTITY,
    id_jugador                   NUMBER NOT NULL,
    fecha_lesion                 DATE NOT NULL,
    tipo_lesion                  VARCHAR2(60) NOT NULL,
    gravedad                     VARCHAR2(20) DEFAULT 'LEVE',
    dias_recuperacion_estimados  NUMBER(4),
    CONSTRAINT pk_lesion PRIMARY KEY (id_lesion),
    CONSTRAINT fk_lesion_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT ck_lesion_gravedad CHECK (gravedad IN ('LEVE','MODERADA','GRAVE')),
    CONSTRAINT ck_lesion_dias     CHECK (dias_recuperacion_estimados >= 0)
);

CREATE TABLE HISTORIAL_CLUB (
    id_historial      NUMBER GENERATED ALWAYS AS IDENTITY,
    id_jugador        NUMBER NOT NULL,
    club_nombre       VARCHAR2(60) NOT NULL,
    temporada         VARCHAR2(9) NOT NULL,
    goles             NUMBER(3) DEFAULT 0,
    asistencias       NUMBER(3) DEFAULT 0,
    partidos_jugados  NUMBER(3) DEFAULT 0,
    CONSTRAINT pk_historial PRIMARY KEY (id_historial),
    CONSTRAINT fk_historial_jugador FOREIGN KEY (id_jugador) REFERENCES JUGADOR(id_jugador),
    CONSTRAINT ck_historial_goles       CHECK (goles >= 0),
    CONSTRAINT ck_historial_asistencias CHECK (asistencias >= 0),
    CONSTRAINT ck_historial_partidos    CHECK (partidos_jugados >= 0)
);

CREATE TABLE COMISION (
    id_comision     NUMBER GENERATED ALWAYS AS IDENTITY,
    id_contrato     NUMBER NOT NULL,
    monto_comision  NUMBER(12,2) NOT NULL,
    fecha_pago      DATE,
    estado_pago     VARCHAR2(20) DEFAULT 'PENDIENTE',
    CONSTRAINT pk_comision PRIMARY KEY (id_comision),
    CONSTRAINT fk_comision_contrato FOREIGN KEY (id_contrato) REFERENCES CONTRATO(id_contrato),
    CONSTRAINT uq_comision_contrato UNIQUE (id_contrato),
    CONSTRAINT ck_comision_estado   CHECK (estado_pago IN ('PENDIENTE','PAGADA')),
    CONSTRAINT ck_comision_monto    CHECK (monto_comision >= 0)
);
