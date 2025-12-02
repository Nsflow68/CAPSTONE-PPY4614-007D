-- Vista para hacer los datos más legibles en DBeaver
-- Puedes consultar esta vista en lugar de las tablas directamente

-- Vista de usuarios con información legible
CREATE OR REPLACE VIEW app.users_readable AS
SELECT 
    -- ID corto para facilitar lectura (primeros 8 caracteres del UUID)
    SUBSTRING(id, 1, 8) as user_id_short,
    -- UUID completo por si se necesita
    id as user_id_full,
    email,
    username,
    name,
    rut,
    TO_CHAR(birthDate, 'DD/MM/YYYY') as fecha_nacimiento,
    gender as genero,
    registrationNumber as numero_registro,
    role as rol,
    TO_CHAR(createdAt, 'DD/MM/YYYY HH24:MI') as fecha_creacion,
    TO_CHAR(updatedAt, 'DD/MM/YYYY HH24:MI') as fecha_actualizacion
FROM app.users
ORDER BY createdAt DESC;

-- Vista de entradas de diario con información legible
CREATE OR REPLACE VIEW app.diary_entries_readable AS
SELECT 
    SUBSTRING(d.id, 1, 8) as entry_id_short,
    SUBSTRING(d.userId, 1, 8) as user_id_short,
    u.email as user_email,
    u.name as user_name,
    TO_CHAR(d.date, 'DD/MM/YYYY') as fecha,
    d.emotions as emociones,
    d.tags as etiquetas,
    TO_CHAR(d.createdAt, 'DD/MM/YYYY HH24:MI') as fecha_creacion
FROM app.diary_entry d
LEFT JOIN app.users u ON d.userId = u.id
ORDER BY d.createdAt DESC;

-- Instrucciones:
-- 1. Ejecutar este script en DBeaver
-- 2. Luego consultar las vistas con:
--    SELECT * FROM app.users_readable;
--    SELECT * FROM app.diary_entries_readable;
-- 3. Los IDs aparecerán acortados (primeros 8 caracteres) para facilitar lectura
-- 4. Las fechas estarán en formato DD/MM/YYYY
-- 5. Los nombres de columnas estarán en español
