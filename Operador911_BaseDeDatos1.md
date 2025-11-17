**Universidad Nacional del Nordeste** 

   
 

**Facultad de Ciencias Exactas y Naturales y Agrimensura** 

 

**Carrera:** Licenciatura en Sistemas de Información 

**Título:** Operador 911

**Cátedra:** Bases de datos 1  
**Año:** 2025   
**Docentes:** Dario O. VILLEGAS

**Grupo Nro 31**

**Alumnos:**  
 

| Nombre                   |     DNI    |
| :-----------------------:|------------|
| Cantero Augusto Joaquin  |    46773711|
| Escalante Joaquin        |    45526785|
| Lezcano Lautaro          |    46381127|
| Carbó Bautista           |    43534330|

 

ÍNDICE

# 

[CAPÍTULO I: INTRODUCCIÓN	3](#capítulo-i:-introducción)

[CAPÍTULO II: MARCO CONCEPTUAL O REFERENCIAL	4](#capítulo-ii:-marco-conceptual-o-referencial)

[CAPÍTULO III: METODOLOGÍA SEGUIDA	4](#capítulo-iii:-metodología-seguida)

[CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS	5](#capítulo-iv:-desarrollo-del-tema-/-presentación-de-resultados)

[CAPÍTULO V: CONCLUSIONES](#capítulo-v:-conclusiones)	9

[CAPÍTULO VI: BIBLIOGRAFÍA.](#capítulo-vi:-bibliografía.)	9

# 

# CAPÍTULO I: INTRODUCCIÓN   

Objetivos del Proyecto

El proyecto tiene como objetivo principal desarrollar e implementar un sistema de operador policial que facilite la gestión de emergencias, denuncias y recursos disponibles en tiempo real. El sistema busca ser ágil, confiable y sencillo de usar para que los operadores puedan responder de manera eficiente y coordinada ante cualquier evento reportado. Algunos de los objetivos clave son:

1\ Registrar y gestionar incidentes: El sistema permitirá gestionar incidentes o emergencias y llamados entrantes, desde el momento que se realiza el llamado hasta el reporte (Carta) generado una vez atendido la alerta .

2\ Administrar recursos disponibles: Se podrá organizar y supervisar la disponibilidad de móviles policiales, asignándolos a los incidentes según prioridad y cercanía, segun el criterio del operador.

3\ Coordinar la respuesta en tiempo real: Los operadores podrán asignar el caso o alerta a una patrulla y dar seguimiento al avance de cada alerta, reduciendo tiempos de respuesta y aprovechando los recursos al maximo.

4\ Centralizar información clave: El sistema almacenará datos de la persona, patrulla y alerta, permitiendo relacionarlos con la alerta generada para mejorar el reporte una vez que se haya atendido.

5\ Generar reportes y estadísticas: Se podrán obtener informes sobre el número de incidentes, tiempo de respuesta. Lo que permitirá mejorar la planificación y la gestión operativa.

6\: Escalabilidad y crecimiento futuro: Aunque el sistema comienza con la gestión básica de incidentes, podria ampliarse para automatizar muchos de los procesos como la geolocalizacion del llamado, el reporte automatizado, el autocompletado de datos en la llamadas, etc

 Alcance del Proyecto

El alcance de este proyecto se centra en cubrir las funciones esenciales para la gestión de emergencias y recursos policiales en tiempo real, manteniendo un diseño simple, ágil y confiable, pero con la posibilidad de crecer en el futuro hacia un sistema más completo y automatizado. El alcance definido contempla las siguientes funcionalidades y limitaciones:

1\ Registro de incidentes y llamados: Captura de la información básica de cada alerta recibida, asociada a la persona que realiza la denuncia.
2\ Gestión de recursos policiales: Administración de patrullas disponibles, permitiendo su asignación según cercanía y prioridad del incidente.
3\ Seguimiento en tiempo real: Posibilidad de controlar el estado de cada incidente desde que es reportado hasta su resolución.
4\ Centralización de información: Almacenamiento organizado de datos de personas, patrullas e incidentes para garantizar trazabilidad y disponibilidad en consultas posteriores.
5\ Generación de reportes: Elaboración de informes y estadísticas sobre cantidad de incidentes, tiempo de respuesta y uso de recursos, útiles para la planificación estratégica.

Limitaciones del Alcance

* El sistema se limita a la **gestión de datos internos** (registro, consulta y seguimiento), sin integrar aún geolocalización en tiempo real ni mapas digitales.
* No se implementa por el momento la grabación o procesamiento de llamadas de audio.
* La asignación de móviles sigue dependiendo del criterio del operador, sin algoritmos de optimización automática.
* Se considera una **fase inicial académica**, con posibilidad de escalar en futuras versiones hacia módulos más avanzados (geolocalización, autocompletado de datos, reportes automatizados, etc.).

El sistema está diseñado como una herramienta de apoyo para los operadores del 911, optimizando los procesos de registro y asignación. Será utilizado principalmente por personal administrativo y operadores de emergencias, y podrá ser consultado por superiores para la generación de reportes y evaluaciones de desempeño.


# CAPÍTULO II: MARCO CONCEPTUAL O REFERENCIAL 
En las últimas décadas, el ámbito de la seguridad pública ha experimentado profundas transformaciones impulsadas por el desarrollo de nuevas tecnologías. Las Tecnologías de la Información y la Comunicación (TICs) han revolucionado la forma en que los organismos de seguridad gestionan incidentes, denuncias y emergencias, permitiendo una respuesta más rápida, organizada y efectiva.

Un ejemplo claro de estas innovaciones es la introducción de sistemas para operar y gestionar emergencias, que permiten la recepción, registro y seguimiento de los llamados, así como la asignación de recursos como vehículos policiales. Sin embargo, el sistema actual presenta serias limitaciones: la persona que atiende el llamado no es la misma que distribuye al personal policial, generando así una división en el proceso. Como resultado, en revisiones posteriores, los únicos registros que se suelen encontrar son las grabaciones de audio, que a menudo son poco útiles y complican la coordinación del oficial con la alerta, ya que no está al tanto de lo que está sucediendo en ese momento.

Frente a esta situación, se hace evidente la necesidad de una actualización tecnológica que permita unificar los procesos, generar registros claros y trazables, y optimizar la coordinación interna. La modernización de estos sistemas no solo mejorará la eficiencia operativa de las fuerzas de seguridad, sino que también garantizará una atención más ágil y precisa hacia la ciudadanía. Además, reducirá la dependencia de grabaciones extensas, favoreciendo la creación de informes estructurados y datos organizados que sirvan para la toma de decisiones y la planificación estratégica.

# CAPÍTULO III: METODOLOGÍA SEGUIDA 
El desarrollo del proyecto se llevo a cabo en distintas partes cada una con un proposito para la correcta implementacion del sistema

1. Fase de Diseño Conceptual: En esta etapa, con ayuda de un operador 911 nos ayudo a comprender mejor como funcionaba el sistema actual dandonos informacion de los flujos claves como por ejemplo: el ingreso de una llamada, la categorizacion de incidentes, despacho de las unidades y el cierre de la alerta. Apartir de ellas pensamos en como mejorarla y definimos las entidades y relaciones necesarias.
Esta fase nos permitio aprender y comprender como funciona el sistema desde que suena el telefono hasta que la patrulla finaliza con su intervencion

2. Fase de Diseño Lógico y Creación de Esquema de Base de Datos:
En esta etapa transformamos el diseño conceptual en un modelo logico que nos permitio entender mucho mas las relaciones y como seria la estructura de nuestra base de datos. En esta etapa se crearon tablas, se definieron claves primarias y foraneas, y se pusieron restricciones como CHECKS, UNIQUES y CONSTRAINT para evitar inconsistencias.

3. Fase de Implementación de Funcionalidades de Seguridad
Dado que se trata de un sistema crítico, se trabajó especialmente en roles, accesos y permisos.  

Roles creados:
* Operador
* Comisario
* Jefe de operadores

Cada uno con su respectivo permiso:
* El operador solo puede registrar llamadas y crear incidentes.
* El comisario tiene la funcion de cargar policias y patrullas a cargo de esa comisaria, tambien tiene la funcionalidad de asignar atraves de una planilla a los policias que van a patrullar.
* El jefe de operadores puede agregar usuarios, ver reportes y crear copias de seguridad o cargar copias de seguridad.

4. Fase de Pruebas y Validación: Se realizaron pruebas para verificar la integridad de los datos, la funcionalidad del sistema y la validación de las reglas de negocio, como la asignacion y el ruteo de una patrulla a una alerta designada.

**Herramientas (Instrumentos y Procedimientos)**
El trabajo se realizó utilizando las siguientes herramientas y procedimientos:

1. **GITHUB**: Se utilizaron para versionar los scripts SQL, cambios en la BD y documentación del sistema  
2. **SQL Server Management Studio (SSMS)**: se utilizo para crear tablas, monitoreo y pruebas del sistema, el desarrollo y escritura de las consultas SQL.  
3. **ERDPlus** Mediante el ERDplus elaboramos los diagramas tanto conceptual como logico a partir de las especificaciones de los requerimientos que fueron surgiendo al plantear el problema en cuestión.   


# CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS 
Lo primero que decidimos implementar fue el diagrama en el modelo relacional y el de entidad-relacion a partir de la investigaciones que hicimos sobre como funcionaba el sistema actual y las modificaciones que proponiamos.
Estos fueron los resultados de ambos diagramas:

![imagen1](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/ModeloRelacional_Operador911.png)

![imagen15](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/EntidadRelacion_Operador911.png)

DICCIONARIO DE DATOS\
Este diccionario de datos documenta las tablas, campos y relaciones de la base de datos del proyecto. Su objetivo es facilitar la comprensión, el desarrollo y el mantenimiento del sistema, asegurando la correcta gestión e integridad de la información.
Accesso al documento [PDF](DER/DiccionarioDeDatos.pdf) del diccionario de datos.


Desarrollo del Sistema

El Sistema de Gestión del Operador 911 fue desarrollado utilizando el entorno de SQL Server, con el objetivo de ofrecer una solución eficiente, segura y ordenada para la administración de llamadas de emergencia, incidentes policiales y la gestión operativa de móviles y personal. A continuación, se describen las principales etapas del desarrollo del sistema.

Modelado de la Base de Datos:

Se llevó a cabo un diagrama entidad-relación para definir las entidades clave del sistema, tales como: **Llamada**, **Canal**, **Reporte**, **Usuario**, **Alerta**, **Comisaria**, **Ubicacion**, **Policia**, **Patrulla**, **Planilla**.En el diagrama se establecieron las relaciones necesarias para reflejar fielmente el flujo operativo y se implementaron las claves primarias (PK) y foráneas (FK) necesarias para mantener la integridad referencial en los datos.

Creación de las Tablas en SQL Server:

Cada entidad se tradujo a una tabla en SQL Server, incorporando las restricciones necesarias como claves primarias y foráneas. Se establecieron restricciones de validación de campos, por ejemplo, el DNI único para los policias y correo para los usuarios. Además, se implementaron restricciones para validar las asignaciones en la planilla, garantizando que no haya solapamientos de horario para el mismo policia.También se implementaron CHECK constraints para controlar valores permitidos, especialmente en estados y tipos de emergencia.

[Script de la Estructura de la Base de Datos](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/Operador911BDD.sql)
Aclaracion: La estructura de la Base de Datos nos la genero el SQL server por el simple hecho de que el mismo proyecto estabamos realizandolo para taller entonces ya teniamos la base de datos armada.

Carga de Datos de Prueba:

Durante la fase de implementación, se centró exclusivamente en las operaciones de inserción de datos enfocadas en poblar la base con datos representativos del sistema de emergencia.. Se registraron datos para Policias, Patrullas, Planilla, Reporte y Alerta, Llamados y demas tablas de la base de datos. No se desarrollaron operaciones de actualización o eliminación, ya que el objetivo principal era validar la estructura, relaciones y comportamiento de los registros en la base.

[Script del Lote de Datos](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/scriptDatosOperador911.sql) 

PRESENTACIÓN DE RESULTADOS:

Los principales resultados del desarrollo fueron los siguientes:

![imagen2](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121011.png)

![imagen3](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121020.png)

![imagen4](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121031.png)

![imagen5](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121039.png)

![imagen6](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121048.png)

![imagen7](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121103.png)

![imagen8](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121111.png)

![imagen9](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/DER/BaseDatos%20y%20Script/lotePruebas/Captura%20de%20pantalla%202025-11-15%20121123.png)

**Desarrollo de los Temas**

[Tema_1](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%202%20Procedimientos%20Almacenados/Tema2ProcedimientosAlmacenados.md):
Los procedimientos almacenados son bloques de código SQL precompilados y almacenados en el servidor que permiten ejecutar operaciones de manera eficiente, segura y reutilizable. Su uso centraliza la lógica de negocio, reduce el tráfico entre cliente y servidor y mejora el rendimiento al reutilizar planes de ejecución ya compilados. Pueden recibir parámetros de entrada y salida, devolver valores, manejar errores mediante TRY…CATCH e incluso controlar transacciones completas. Existen distintos tipos, como procedimientos definidos por el usuario, del sistema, recursivos o temporales, todos útiles para automatizar tareas, validar datos y restringir el acceso directo a las tablas. Al ejecutarse dentro del motor de la base de datos, aprovechan los mecanismos de concurrencia y aislamiento para garantizar integridad y consistencia, convirtiéndose en una herramienta esencial para el diseño de sistemas robustos, modulares y seguros.

[Tema_2](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Optimizaci%C3%B3n_de_consultas_a_trav%C3%A9s_de_%C3%ADndices.md):
El proyecto evaluó cómo distintos tipos de índices mejoran el rendimiento de consultas en una tabla de un millón de registros, analizando tres escenarios: sin índice, con índice agrupado y con un índice no agrupado cubriente. Se comprobó que el Table Scan del escenario base obligaba al motor a leer toda la tabla, generando más de 10.000 lecturas lógicas. Al aplicar un índice agrupado sobre fecha_creacion, las búsquedas por rango se optimizaron significativamente, reduciendo las lecturas a 1.680 gracias a un acceso ordenado y directo a los datos. El mejor rendimiento se obtuvo con el índice cubriente, que permitió resolver la consulta sin acceder a la tabla base, reduciendo las lecturas a solo 1.157. Aunque los tiempos de ejecución fueron similares debido al uso de caché, las métricas reales demostraron que los índices —especialmente los cubrientes— son esenciales para optimizar consultas en sistemas de gran volumen y mejorar la eficiencia del motor de base de datos.

[Tema_3](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%201%20Manejo%20de%20Transacciones/Manejo%20de%20Transacciones%20y%20Transaccion.md): 
El manejo de transacciones en bases de datos garantiza que un conjunto de operaciones se ejecute de forma íntegra y segura, manteniendo siempre la consistencia del sistema gracias a las propiedades ACID (atomicidad, consistencia, aislamiento y durabilidad). Las transacciones pueden ser planas o anidadas, permitiendo estas últimas organizar procesos complejos mediante subtransacciones, aunque en SQL Server solo la transacción externa controla realmente el commit y el rollback. Según el orden de lectura y escritura, existen transacciones generales, restringidas y de dos pasos, mientras que SQL Server ofrece modos automáticos, explícitos e implícitos para gestionarlas. En entornos centralizados y distribuidos, el control de concurrencia, la integridad, la coordinación entre nodos y los protocolos de recuperación son esenciales para garantizar que los datos permanezcan correctos incluso ante fallas. En conjunto, las transacciones permiten ejecutar operaciones críticas con seguridad, eficiencia y confiabilidad, fortaleciendo la integridad de los sistemas de información.

[Tema_4](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%204%20Triggers/Triggers.md):
Los triggers son objetos de la base de datos que se ejecutan automáticamente cuando ocurre un evento como INSERT, UPDATE o DELETE, permitiendo automatizar tareas sin intervención del usuario. Se utilizan para auditoría, seguridad, validaciones y acciones automáticas entre tablas. En SQL Server existen triggers AFTER, que se ejecutan una vez completada la operación, e INSTEAD OF, que la reemplazan para modificar o bloquear su comportamiento. Trabajan con las tablas lógicas inserted y deleted, que guardan los valores nuevos y anteriores para comparar cambios. Sus ventajas incluyen garantizar reglas de integridad y registrar auditoría incluso si la aplicación no lo hace, aunque requieren cuidado porque pueden afectar la performance y volver el sistema difícil de mantener. En el proyecto aplicado, los triggers se usaron para auditar cambios en la tabla Alerta y para impedir la eliminación de usuarios, aportando trazabilidad y mayor integridad al sistema.


# CAPÍTULO V: CONCLUSIONES  

El desarrollo del proyecto “Sistema de Gestión del Operador 911” permitió integrar los contenidos teóricos y prácticos, aplicándolos a un caso real que demanda organización, seguridad y eficiencia en el manejo de la información. A lo largo del trabajo se diseñó, implementó y probó una base de datos capaz de representar el flujo operativo de un centro de emergencias, desde la recepción de llamados hasta la asignación de recursos policiales y la generación de reportes.

En primer lugar, la construcción del modelo conceptual y lógico facilitó comprender en profundidad los procesos actuales del sistema 911, permitiendo reorganizarlos y mejorarlos para obtener una estructura de datos coherente, trazable y escalable. A partir de este diseño se implementaron tablas, relaciones y restricciones que aseguraron la integridad referencial y la consistencia de la información almacenada.

La implementación de procedimientos almacenados, índices, transacciones y triggers permitió profundizar en los temas centrales de la asignatura y comprender su importancia en sistemas reales:

* Los procedimientos almacenados demostraron ser fundamentales para centralizar la lógica de negocio, mejorar el rendimiento y simplificar operaciones repetitivas.

* El estudio de la optimización mediante índices evidenció mejoras significativas en la eficiencia de consultas, especialmente con índices cubrientes, que redujeron notoriamente las lecturas lógicas en tablas con grandes volúmenes de datos.

* El análisis del manejo de transacciones permitió comprender cómo garantizar integridad y confiabilidad en operaciones críticas, evitando inconsistencias ante fallas o accesos concurrentes.

* Los triggers aportaron auditoría, seguridad y automatización, reforzando la trazabilidad en tablas sensibles como Alerta y previniendo acciones que podrían comprometer la estabilidad del sistema.

En conjunto, todos estos componentes dieron lugar a un sistema robusto, ordenado y funcional, que refleja fielmente los principios fundamentales del diseño de bases de datos relacionales. Además, el proyecto permitió valorar la importancia de la planificación, la documentación y las pruebas en cada etapa de desarrollo. Como resultado, se logró generar una base sólida que podría ser ampliada en futuras versiones, incorporando módulos avanzados como geolocalización en tiempo real, integración con sistemas externos y automatización de reportes.


# CAPÍTULO VI: BIBLIOGRAFÍA. 

1. Ambler, S. W. (s.f.). Transaction control. AgileData.org. https://agiledata.org/essays/transactioncontrol.html
2. Microsoft. (2025). BEGIN TRANSACTION (Transact-SQL). Microsoft Learn. https://learn.microsoft.com/es-es/sql/t-sql/language-elements/begin-transaction-transact-sql
3. Jeremiah, O. (2023). Transacciones SQL: Qué son y cómo usarlas. DataCamp. https://datacamp.com/es/tutorial/sql-transactions
4. Microsoft. (2025). Microsoft Learn. https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver17
5. W3Schools. SQL Stored Procedures for SQL Server. https://www.w3schools.com/sql/sql_stored_procedures.asp
6. Microsoft (2025). *SQL Server Index Design Guide*. Recuperado de: `https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-index-design-guide`
7. Microsoft (2025). *Indexes - SQL Server*. Recuperado de: `https://learn.microsoft.com/es-es/sql/relational-databases/indexes/indexes?view=sql-server-ver16`

