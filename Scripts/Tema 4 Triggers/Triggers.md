# Triggers en Bases de Datos  

## 1. ¿Qué es un trigger?
Un trigger (o “disparador”) es un objeto de la base de datos que se ejecuta automáticamente ante ciertos eventos sobre una tabla.  
Los eventos más comunes son:  
- **INSERT**  
- **UPDATE**  
- **DELETE**

La idea principal es que no hace falta que el usuario invoque nada: cuando ocurre el evento, el trigger se activa solo.  
Esto permite automatizar tareas, controlar operaciones y registrar acciones sobre los datos.

---

## 2. ¿Para qué se utilizan?
Los triggers suelen utilizarse para resolver problemas que no se pueden (o no es conveniente) manejar desde la aplicación.  
Algunos usos típicos son:

### ✔ Auditoría  
Registrar quién modificó o borró datos, qué valores tenían antes y cuándo ocurrió la operación.

### ✔ Seguridad e Integridad  
Evitar operaciones no autorizadas, como borrar usuarios o modificar datos críticos.

### ✔ Validaciones  
Comprobar reglas antes de aceptar una operación (por ejemplo, impedir que el stock quede negativo).

### ✔ Automatización  
Generar registros automáticamente en tablas relacionadas cuando ocurre algún cambio.

---

## 3. Tipos de triggers en SQL Server
SQL Server permite varios tipos de triggers:

### **AFTER INSERT / UPDATE / DELETE**  
Se ejecutan *después* de realizarse la operación.  
Son útiles para auditorías porque permiten acceder a las tablas lógicas `inserted` y `deleted`.

### **INSTEAD OF INSERT / UPDATE / DELETE**  
Reemplazan la operación original.  
Se usan para bloquear un DELETE o modificar el comportamiento por defecto.

---

## 4. Tablas lógicas: `inserted` y `deleted`
Los triggers trabajan con dos tablas internas generadas por SQL Server:

- **inserted** → contiene los valores nuevos (después del INSERT o UPDATE).  
- **deleted** → contiene los valores anteriores (antes del DELETE o UPDATE).

Estas dos tablas permiten comparar cambios sin perder información.

---

## 5. Ventajas de usar triggers
- Garantizan integridad y reglas que se ejecutan sí o sí.  
- Permiten registrar auditoría incluso si la aplicación no lo hace.  
- Funcionan en todos los clientes que usen la base (web, desktop, scripts, etc.).  

---

## 6. Desventajas o precauciones
- Si se abusa de ellos, pueden complicar el mantenimiento.  
- Un trigger mal hecho puede afectar la performance.  
- Es importante documentarlos y probarlos bien para que no generen efectos inesperados.

---

## 7. Conclusiones
Los triggers son una herramienta poderosa y muy útil cuando se usan de manera correcta.  
En nuestro proyecto, los implementamos de dos formas. En primer lugar, con fines de auditoría, registrando las modificaciones y eliminaciones de la tabla **Alerta**, ya que consideramos que es una tabla importante dada la naturaleza del sistema y es conveniente dejar registradas todas las modificaciones que ocurran en ella. Además implementamos un trigger de seguridad que evita la eliminación de usuarios, ya que eliminar un usuario podria desencadenar errores que afecten seriamente al sistema.  
Esto aporta trazabilidad, mejora la integridad del sistema y refleja situaciones reales en las que la información no debe perderse o eliminarse sin control.