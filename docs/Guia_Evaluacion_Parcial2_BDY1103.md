# GUÍA DE APOYO PARA EL ESTUDIANTE

**Evaluación Parcial N°2 — BDY1103 · Taller de Base de Datos**

*Implementación de programas PL/SQL en una base de datos: estructura del informe, estructura de la presentación, casos a resolver y pauta de evaluación, aplicados al caso Renta House.*

Este documento orienta el desarrollo de la Evaluación Parcial N°2 de la asignatura Taller de Base de Datos. Define el alcance del trabajo, la estructura que debe seguir el informe, la estructura de la presentación y la pauta de evaluación (rúbrica) con la que se calificará cada indicador. Léanlo íntegramente antes de comenzar el desarrollo.

## 0. Resumen de la evaluación

La Evaluación Parcial N°2 corresponde al 40% de la asignatura y se compone de dos situaciones evaluativas. El desarrollo se realiza en equipos de hasta 3 estudiantes, en taller de alto cómputo, durante 1 semana. Cada situación evaluativa se califica de forma individual.

| **Situación evaluativa** | **Tipo**                     | **% de la Evaluación Parcial 2** |
|--------------------------|------------------------------|----------------------------------|
| 1                        | Entrega de encargo (informe) | 40%                              |
| 2                        | Presentación                 | 60%                              |

> **Continuidad con la Evaluación Parcial N°1**
>
> Cada evaluación parcial es una parte del examen transversal: el caso se divide en tres partes, una por cada evaluación. Por eso se sugiere continuar con el mismo contexto de negocio trabajado en la Evaluación Parcial N°1 —por ejemplo, el modelo Renta House—, de modo que el equipo concentre su esfuerzo en construir los nuevos objetos PL/SQL y no en levantar un modelo nuevo.
>
> Las técnicas de la evaluación anterior (RECORD, VARRAY, cursores explícitos y excepciones) pueden y deben reutilizarse dentro de los nuevos objetos: un procedimiento que recorre datos con un cursor o una función que controla NO_DATA_FOUND son ejemplos naturales de esa integración.

## 1. Estructura de la entrega

La entrega debe incluir los siguientes elementos. Cada uno se revisa por separado, por lo que deben entregarse como archivos independientes y correctamente identificados.

| **Entregable**        | **Formato**                                                                                                                      | **Detalle**                                                                                                                                                                                                                |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Presentación**      | Archivo PowerPoint<br>(Presentación.pptx)                                                                                        | Solo el archivo de PowerPoint. No debe exportarse a PDF ni a ningún otro formato.                                                                                                                                          |
| **Informe**           | Documento en PDF<br>(Informe.PDF)                                                                                                | El informe completo, con la estructura definida en la sección 4 de este documento, exportado a PDF.                                                                                                                        |
| **Códigos fuente**    | Archivos .sql, uno por requerimiento<br>Requerimiento 1.SQL<br>Requerimiento 2.SQL<br>Requerimiento 3.SQL<br>Requerimiento 4.SQL | Cuatro archivos .sql independientes: procedimientos almacenados; funciones almacenadas; package (especificación y cuerpo); triggers. Cada archivo incluye la creación de los objetos y las sentencias con que se probaron. |
| **Modelo de datos**   | Diagrama (PDF o PNG)<br>Diagrama.PDF o Diagrama.PNG                                                                              | Modelo de datos del contexto elegido, legible y claro, con entidades, atributos y relaciones correctamente identificados. Si se agregaron tablas nuevas (por ejemplo, de auditoría), deben aparecer en el modelo.          |
| **Script de carga**   | Archivo .sql<br>Script de Carga.SQL                                                                                              | Creación de las tablas (DDL) y poblado de datos (INSERT) necesario para que los cuatro requerimientos puedan ejecutarse de principio a fin, incluidas las tablas de apoyo que usen los triggers.                           |
| **Contexto del caso** | Documento breve (PDF)<br>Contexto.PDF                                                                                            | Descripción del negocio elegido y del problema que resuelve el proyecto, redactada de forma que pueda leerse de manera independiente, sin necesidad de revisar el código.                                                  |

> **Organización sugerida de los archivos**
>
> Se sugiere agrupar todo en una carpeta (o archivo .zip) con la siguiente estructura: una subcarpeta "presentacion" con el .pptx, una subcarpeta "informe" con el .pdf, una subcarpeta "codigo_fuente" con los 4 archivos .sql (uno por requerimiento), una subcarpeta "modelo_datos" con el diagrama, y una subcarpeta "script_carga" con el .sql de creación y poblado. El contexto del caso puede incluirse como documento aparte o como primera sección del informe.
>
> El archivo comprimido debe ser solo en formato ZIP. Ejemplo de nombre: Taller BD Galaz Rios Saez.ZIP

## 2. Alcance del trabajo

Para esta evaluación, el desarrollo debe cubrir cuatro tipos de objetos PL/SQL almacenados en la base de datos: procedimientos almacenados (con y sin parámetros), funciones almacenadas (con y sin parámetros), packages (con constructores públicos y privados) y triggers asociados a tablas (a nivel de sentencia y a nivel de fila).

- **Un solo contexto de negocio:** los cuatro tipos de objetos deben desarrollarse sobre el mismo problema de negocio, no como ejercicios sueltos. La evaluación exige una "solución integral de procesamiento y generación de información".

- **Objetos que se usan entre sí:** los objetos deben relacionarse entre sí. Por ejemplo: el package agrupa procedimientos y funciones del proyecto; un procedimiento usa una función; un trigger invoca un elemento del package. Un objeto que no se usa en ninguna parte difícilmente demuestra una solución integral.

- **Procesamiento masivo:** la pauta pide procesar "información masiva": los procedimientos y funciones deben trabajar sobre conjuntos de datos (muchas filas), no solo sobre un registro aislado.

*En el resto de este documento, estos cuatro objetos se identifican como "Requerimiento 1" a "Requerimiento 4".*

## 3. Tipos de problemas / casos a resolver

A continuación se detallan los cuatro requerimientos que debe cubrir el proyecto, junto con un ejemplo aplicado al modelo Renta House para cada uno. El ejemplo puede tomarse como base o adaptarse al contexto de negocio que elija cada equipo.

### Requerimiento 1 — Procedimientos almacenados con y sin parámetros

**Indicadores:** IE2.1.1 (informe) e IE2.1.2 (presentación) · Ponderación combinada: 10% + 15% = 25%

**Objetivo técnico:** Construir procedimientos almacenados, con y sin parámetros, que procesen información masiva y que sean invocados desde otros programas PL/SQL, ejecutando sentencias SQL sobre los datos del negocio.

**Ejemplo sugerido (Renta House):** "Reajuste anual de arriendos": un procedimiento sin parámetros que recorre todas las propiedades con arriendo vigente y aplica el reajuste del año, y un procedimiento con parámetros (por ejemplo, comuna y porcentaje, más un parámetro OUT que devuelva cuántas propiedades se reajustaron) que aplica el reajuste solo a una comuna. Ambos se invocan desde otro bloque o desde el package del Requerimiento 3.

**Qué debe quedar evidenciado:**

- Al menos un procedimiento sin parámetros y al menos uno con parámetros, indicando el modo de cada parámetro (IN, OUT o IN OUT).

- El procedimiento procesa un conjunto de filas (por ejemplo, recorriendo un cursor), no un único registro.

- El procedimiento es invocado desde otro programa PL/SQL (bloque anónimo, otro procedimiento, el package o un trigger).

- Se explica por qué ese proceso se resolvió con un procedimiento y no con una función.

### Requerimiento 2 — Funciones almacenadas con y sin parámetros

**Indicadores:** IE2.1.3 (informe) e IE2.1.4 (presentación) · Ponderación combinada: 10% + 15% = 25%

**Objetivo técnico:** Construir funciones almacenadas, con y sin parámetros, que calculen y retornen información del negocio, y que se usen tanto dentro de sentencias SQL como desde otros programas PL/SQL.

**Ejemplo sugerido (Renta House):** "Costo mensual y disponibilidad": una función con parámetro que retorna el costo mensual total de una propiedad (arriendo + gasto común), usada en un SELECT que lista la cartera completa; y una función sin parámetros que retorna la cantidad de propiedades disponibles (sin arriendo vigente), usada dentro de un procedimiento o de un reporte.

**Qué debe quedar evidenciado:**

- Al menos una función sin parámetros y al menos una con parámetros, ambas con RETURN en todos sus caminos de ejecución.

- La función se usa dentro de una sentencia SQL (SELECT, WHERE u ORDER BY) aplicada a muchas filas.

- La función se usa también desde otro programa PL/SQL (procedimiento, package o trigger).

- Se controla el caso en que el dato no existe (por ejemplo, NO_DATA_FOUND) y se explica qué retorna la función en ese caso.

### Requerimiento 3 — Packages con constructores públicos y privados

**Indicadores:** IE2.2.1 (informe) e IE2.2.2 (presentación) · Ponderación combinada: 10% + 15% = 25%

**Objetivo técnico:** Construir un package, con especificación y cuerpo, que agrupe los objetos del proyecto en una solución integral, exponiendo solo lo necesario (constructores públicos) y ocultando la lógica interna (constructores privados).

**Ejemplo sugerido (Renta House):** "pkg_gestion_arriendos": en la especificación se publican el procedimiento de reajuste y la función de costo mensual; en el cuerpo se agrega una función privada que valida si una propiedad existe y una variable o constante interna (por ejemplo, el porcentaje máximo de reajuste). Otros bloques y los triggers usan el package con la notación paquete.elemento.

**Qué debe quedar evidenciado:**

- El package tiene especificación (PACKAGE) y cuerpo (PACKAGE BODY), compilados sin errores.

- Al menos un constructor público (declarado en la especificación) y al menos uno privado (que existe solo en el cuerpo).

- El package agrupa procedimientos y/o funciones del proyecto y es usado por otro proceso: bloque anónimo, trigger u otro package.

- Se explica qué se decidió dejar público, qué se ocultó y por qué.

### Requerimiento 4 — Triggers a nivel de sentencia y de fila

**Indicadores:** IE2.3.1 (informe) e IE2.3.2 (presentación) · Ponderación combinada: 10% + 15% = 25%

**Objetivo técnico:** Construir triggers asociados a tablas del modelo que controlen acciones tanto a nivel de fila (FOR EACH ROW) como a nivel de sentencia, integrados a la solución.

**Ejemplo sugerido (Renta House):** "Control y auditoría de arriendos": un trigger a nivel de fila sobre PROPIEDAD que registra en una tabla de auditoría el valor anterior y el nuevo del arriendo (:OLD y :NEW), o que impide rebajas mayores a un porcentaje; y un trigger a nivel de sentencia que registra una sola vez cada operación masiva (por ejemplo, el reajuste anual del Requerimiento 1).

**Qué debe quedar evidenciado:**

- Al menos un trigger a nivel de fila y al menos uno a nivel de sentencia, asociados a tablas del modelo.

- Se justifica el momento elegido (BEFORE o AFTER) y el evento que lo dispara (INSERT, UPDATE o DELETE).

- El trigger de fila usa :NEW y/o :OLD con un propósito de negocio claro.

- Se demuestra el disparo de cada trigger con una sentencia real y su resultado (por ejemplo, el registro que quedó en la tabla de auditoría).

## 4. Estructura del informe (Situación evaluativa 1)

Esta es la estructura de apartados exigida por la pauta. Bajo cada uno se detalla el contenido que debe desarrollarse.

### Introducción

- **Contexto del proyecto:** contexto de negocio del proyecto y el problema que se aborda.

- **Descripción del proyecto:** objetivo del proyecto y cómo los distintos objetos PL/SQL (procedimientos, funciones, packages y triggers) se usarán para cumplirlo.

- **Datos e información:** qué datos se procesan y qué información relevante se necesita generar a partir de ellos.

- **Alcance:** componentes del negocio que se ven afectados o mejorados por el desarrollo de estos objetos.

- **Tecnologías utilizadas:** Oracle, herramientas de desarrollo, versión, etc.

### Desarrollo de procedimientos y funciones

- **Definición y características:** qué es un procedimiento almacenado y qué es una función almacenada.

- **Ventajas y desventajas:** de cada uno, y en qué se diferencian.

- **Propósito en el proyecto:** qué resuelve cada procedimiento y cada función dentro del contexto de negocio.

- **Uso en el proyecto:** describir y demostrar cómo se utilizaron: con y sin parámetros, invocados desde otros programas PL/SQL y, en el caso de las funciones, dentro de sentencias SQL.

### Desarrollo de packages

- **Definición y características:** especificación, cuerpo, constructores públicos y privados.

- **Ventajas y desventajas:** de utilizar packages.

- **Organización del código:** cómo el package ayuda a organizar el código del proyecto.

- **Relación con procedimientos y funciones:** qué procedimientos y funciones agrupa y cómo se invocan a través del package.

- **Uso en el proyecto:** describir y demostrar cómo se utilizó el package en el contexto del proyecto.

### Desarrollo de triggers

- **Definición y características:** momento, evento y nivel (fila o sentencia).

- **Ventajas y desventajas:** de utilizar triggers.

- **Propósito en el proyecto:** qué controla o automatiza cada trigger.

- **Uso en el proyecto:** demostrar cómo se dispararon los triggers, con la sentencia que los activa y su resultado.

### Conclusión

- **Resumen:** los puntos principales del informe, en pocas líneas.

- **Impacto del proyecto:** cómo la utilización de procedimientos, funciones, packages y triggers contribuyó a la solución propuesta.

- **Recomendaciones:** mejoras futuras o áreas donde se podría extender el uso de PL/SQL.

### Anexos

- **Código completo:** todo el código PL/SQL del proyecto: creación de los objetos y sentencias de prueba.

- **Diagramas y modelos:** modelo de datos, diagramas de flujo o esquemas usados (por ejemplo, un diagrama de qué objeto usa a cuál).

## Bibliografía (APA)

La bibliografía debe listar, en formato APA (7ª edición), todas las fuentes efectivamente consultadas durante el desarrollo del proyecto: apuntes de clases subidos al AVA, material compartido por el docente (por ejemplo, en Drive), documentación oficial de las tecnologías utilizadas, y cualquier herramienta de inteligencia artificial o agente usado como apoyo. Las referencias se ordenan alfabéticamente por apellido del autor o nombre de la organización, con sangría francesa en cada una.

| **Tipo de fuente**               | **Qué citar**                                                                                                               | **Formato APA (ejemplo)**                                                                                  |
|----------------------------------|-----------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| **Apuntes de clases (AVA)**      | Presentaciones, guías o documentos subidos al Ambiente Virtual de Aprendizaje que se hayan usado para resolver el proyecto. | Apellido, N. (Año). Título del apunte \[Apunte de clase\]. Ambiente Virtual de Aprendizaje (AVA), Duoc UC. |
| **Recursos del docente (Drive)** | Material compartido por el docente fuera del AVA: plantillas, ejemplos resueltos, scripts base, etc.                        | Apellido, N. (Año). Título del recurso \[Documento compartido\]. Google Drive del curso, Duoc UC.          |
| **Documentación oficial**        | Manuales o páginas de referencia de Oracle u otra tecnología utilizada en el proyecto.                                      | Oracle Corporation. (Año). Título de la página. Oracle Help Center. URL                                    |
| **Herramientas de IA o agentes** | Cualquier IA o agente usado como apoyo (ChatGPT, Claude, Copilot, etc.), indicando la versión utilizada.                    | Empresa. (Año). Nombre de la herramienta (versión) \[Modelo de lenguaje de gran tamaño\]. URL              |
| **Otros recursos web**           | Tutoriales, foros, artículos o videos consultados fuera del material del curso.                                             | Apellido, N. (Año, día de mes). Título del recurso. Nombre del sitio. URL                                  |

> **Sobre el uso de IA en la bibliografía**
>
> Toda herramienta de inteligencia artificial o agente que haya sido utilizado como apoyo en el desarrollo del proyecto debe quedar citada en la bibliografía, junto con una breve indicación de en qué parte del trabajo se usó. Usar IA como apoyo no es un problema; no declararlo sí lo es.

## 5. Estructura de la presentación (Situación evaluativa 2)

La presentación se organiza en la siguiente secuencia de diapositivas, acorde al alcance definido en la sección 2 de este documento. Cada equipo puede ajustar el número exacto de diapositivas, pero el orden y el contenido de cada bloque no debe omitirse.

- **1. Portada:** equipo, asignatura, fecha, nombre del proyecto.

- **2-3. El problema y su contexto (punto a):** qué problema de negocio aborda el proyecto, por qué es relevante y su impacto potencial. Explicación clara y bien estructurada: esto se evalúa explícitamente.

- **4. Datos e información a generar:** qué datos existen y qué información nueva producen los objetos desarrollados.

- **5-6. Procedimientos y funciones (punto b):** qué hace cada uno, con y sin parámetros, dónde se invocan y por qué cada proceso se resolvió con un procedimiento o con una función. Fragmentos de código breves y legibles.

- **7. Packages (punto c):** qué agrupa el package, qué es público, qué es privado y por qué.

- **8. Triggers (punto d):** qué controla cada trigger, cuál es de fila y cuál de sentencia, y por qué se eligió ese momento y evento.

- **9. Demostración:** una demo breve (en vivo o con capturas reales) de los objetos funcionando con datos reales: un procedimiento ejecutado, una función dentro de un SELECT y un trigger disparándose.

- **10. Conclusión (punto e):** cierre de lo presentado: qué se logró y qué aportó.

- **11. Preguntas:** espacio abierto: el docente puede pedir profundizar en cualquier parte.

**Tiempo de la presentación:** 10 a 15 minutos.

**Consejos para la presentación (de la pauta)**

- Cada diapositiva debe transmitir un mensaje claro y conciso: sin sobrecargar de texto; usar viñetas y gráficos para enfatizar los puntos clave.

- Usar diagramas, gráficos y ejemplos de código relevantes, legibles y enfocados.

- Ensayar la presentación para ajustarse al tiempo asignado, con transiciones fluidas entre diapositivas.

- Estar preparados para responder preguntas y profundizar en cualquier parte si el docente lo pide.

## 6. Checklist de autoevaluación antes de entregar

Cada fila corresponde a un indicador de la pauta oficial de evaluación. Revisen que ambas columnas (informe y presentación) estén cubiertas para las 4 filas antes de entregar.

| **Indicador**                                           | **% Informe (construye)** | **% Presentación (justifica)** |
|---------------------------------------------------------|---------------------------|--------------------------------|
| IE2.1 — Procedimientos almacenados con y sin parámetros | 10% (IE2.1.1)             | 15% (IE2.1.2)                  |
| IE2.1 — Funciones almacenadas con y sin parámetros      | 10% (IE2.1.3)             | 15% (IE2.1.4)                  |
| IE2.2 — Packages con constructores públicos y privados  | 10% (IE2.2.1)             | 15% (IE2.2.2)                  |
| IE2.3 — Triggers a nivel de sentencia y de fila         | 10% (IE2.3.1)             | 15% (IE2.3.2)                  |
| **Total**                                               | **40%**                   | **60%**                        |

*Los indicadores que dicen "Construye" se evalúan en el informe y el código entregado; los que dicen "Justifica" se evalúan en la presentación y la defensa oral. Entre ambos suman el 100% de la pauta.*

> **Recordatorio final**
>
> La evaluación de cada situación (informe y presentación) es individual, aunque el desarrollo se realice en equipo. En la presentación, cada integrante debe poder explicar y justificar el proyecto completo —los cuatro tipos de objetos y cómo se relacionan—, no solo la parte que desarrolló.

## 7. Rúbrica oficial de evaluación

A continuación se presenta la pauta oficial de evaluación (rúbrica), correspondiente a los indicadores de esta evaluación. Utilícenla como referencia detallada de desempeño: para obtener el 100% de un indicador, el trabajo debe corresponder íntegramente a la columna "Muy buen desempeño", no solo aproximarse a la idea general del indicador.

## Escala general de niveles de logro

Esta misma escala de 5 niveles se aplica a cada indicador.

| **Categoría**            | **% logro** | **Descripción**                                                                                                                                                                                   |
|--------------------------|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Muy buen desempeño**   | 100%        | Demuestra un desempeño destacado, evidenciando el logro de todos los aspectos evaluados en el indicador.                                                                                          |
| **Buen desempeño**       | 80%         | Demuestra un alto desempeño del indicador, presentando pequeñas omisiones, dificultades y/o errores.                                                                                              |
| **Desempeño aceptable**  | 60%         | Demuestra un desempeño competente, evidenciando el logro de los elementos básicos del indicador, pero con omisiones, dificultades o errores.                                                      |
| **Desempeño incipiente** | 30%         | Presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador, por lo que no puede ser considerado competente. |
| **Desempeño no logrado** | 0%          | Presenta ausencia o incorrecto desempeño.                                                                                                                                                         |

## Situación evaluativa 1 — Informe (evaluación individual)

### IE2.1.1 — Procedimientos almacenados — informe

**Ponderación en la pauta oficial:** 10%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Construye correctamente procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL.                                                                                                                                          |
| **80%**   | Construye procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Construye procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Construye procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No construye procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.1.3 — Funciones almacenadas — informe

**Ponderación en la pauta oficial:** 10%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                       |
|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Construye correctamente funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL.                                                                                                                                          |
| **80%**   | Construye funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Construye funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Construye funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No construye funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.2.1 — Packages — informe

**Ponderación en la pauta oficial:** 10%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                                                                     |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Construye correctamente packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones.                                                                                                                                          |
| **80%**   | Construye packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Construye packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Construye packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No construye packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.3.1 — Triggers — informe

**Ponderación en la pauta oficial:** 10%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                                    |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Construye correctamente triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información.                                                                                                                                          |
| **80%**   | Construye triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Construye triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Construye triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No construye triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información o lo realiza de forma incorrecta.                                                                                                                    |

## Situación evaluativa 2 — Presentación (evaluación individual)

### IE2.1.2 — Procedimientos almacenados — presentación

**Ponderación en la pauta oficial:** 15%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                     |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Justifica correctamente la implementación de procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL.                                                                                                                                          |
| **80%**   | Justifica la implementación de procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Justifica la implementación de procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Justifica la implementación de procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No justifica la implementación de procedimientos con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.1.4 — Funciones almacenadas — presentación

**Ponderación en la pauta oficial:** 15%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                            |
|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Justifica correctamente la implementación de funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL.                                                                                                                                          |
| **80%**   | Justifica la implementación de funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Justifica la implementación de funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Justifica la implementación de funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No justifica la implementación de funciones almacenadas con y sin parámetros para procesar información masiva, y ser usadas en otros programas PL/SQL y en sentencias SQL o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.2.2 — Packages — presentación

**Ponderación en la pauta oficial:** 15%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                                                                                          |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Justifica correctamente la implementación de packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones.                                                                                                                                          |
| **80%**   | Justifica la implementación de packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Justifica la implementación de packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Justifica la implementación de packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No justifica la implementación de packages con constructores públicos y privados, en la base de datos, para elaborar una solución integral de procesamiento y generación de información o ser usados en otros procesos y/o aplicaciones o lo realiza de forma incorrecta.                                                                                                                    |

### IE2.3.2 — Triggers — presentación

**Ponderación en la pauta oficial:** 15%

| **Nivel** | **Descripción textual de la pauta**                                                                                                                                                                                                                                                                                                                         |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **100%**  | Justifica correctamente la implementación de triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información.                                                                                                                                          |
| **80%**   | Justifica la implementación de triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presentando pequeñas omisiones, dificultades y/o errores.                                                                                         |
| **60%**   | Justifica la implementación de triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presenta omisiones, dificultades y/o errores.                                                                                                     |
| **30%**   | Justifica la implementación de triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información, pero presenta importantes omisiones, dificultades o errores en el desempeño, que no permiten evidenciar los elementos básicos del logro del indicador. |
| **0%**    | No justifica la implementación de triggers asociados a tablas que controlen acciones a nivel de sentencia y de filas, para elaborar una solución integral de procesamiento y generación de información o lo realiza de forma incorrecta.                                                                                                                    |
