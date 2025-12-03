# Guía para Visualizar Datos en DBeaver

## Problema
Los IDs de usuario aparecen como UUIDs largos (ej: `4328dc1c-9e3f-48cd-b0ec-2f198eb8a2da`) que son difíciles de leer.

## Solución
He creado vistas SQL que hacen los datos más legibles.

## Pasos para tu compañero

### 1. Actualizar DBeaver
1. En el panel de navegación (izquierda), hacer clic derecho sobre la conexión de base de datos.
2. Seleccionar **Refresh** (Actualizar) o presionar `F5`.
3. Navegar a: `Schemas` -> `app` -> `Views`.
4. Debería aparecer la vista `users_readable`.

### 2. Consultar los datos
Ejecutar esta consulta SQL:

```sql
SELECT * FROM app.users_readable;
```

### 3. Resultado esperado
Verá una tabla con:
- **user_id_short**: ID corto (ej: `4328dc1c`)
- **rut**: El RUT del usuario
- **fecha_nacimiento**: Fecha formateada
- **genero**: Género
- **numero_registro**: N° Registro
- **user_id_full**: El ID completo (por si lo necesita)

### 4. Si necesita el ID completo

El ID completo sigue disponible en la columna `user_id_full` por si lo necesita para hacer joins o búsquedas.

## Ejemplo de resultado

Antes (tabla original):
```
id: 4328dc1c-9e3f-48cd-b0ec-2f198eb8a2da
createdAt: 2025-12-02 15:34:24.585
```

Después (vista readable):
```
user_id_short: 4328dc1c
fecha_creacion: 02/12/2025 15:34
```

## Consultas útiles adicionales

**Buscar usuario por email:**
```sql
SELECT * FROM app.users_readable WHERE email LIKE '%ejemplo%';
```

**Ver últimos 10 usuarios registrados:**
```sql
SELECT * FROM app.users_readable LIMIT 10;
```

**Ver entradas de diario de un usuario específico:**
```sql
SELECT * FROM app.diary_entries_readable 
WHERE user_email = 'usuario@ejemplo.com';
```
