-- Script para verificar que los IDs de usuarios sean legibles en DBeaver
-- Ejecutar este script en DBeaver para ver los datos claramente

-- Ver estructura de la tabla users
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'app' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- Ver usuarios con todos sus campos (incluyendo los nuevos)
SELECT 
    id,
    email,
    username,
    name,
    rut,
    TO_CHAR(birthDate, 'YYYY-MM-DD') as birth_date,
    gender,
    registrationNumber as registration_number,
    role,
    TO_CHAR(createdAt, 'YYYY-MM-DD HH24:MI:SS') as created_at
FROM app.users
ORDER BY createdAt DESC
LIMIT 10;

-- Verificar que los IDs NO estén hasheados (deben ser UUIDs legibles)
-- Los UUIDs tienen formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
SELECT 
    id,
    email,
    CASE 
        WHEN id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' 
        THEN 'UUID válido ✓'
        ELSE 'NO es UUID ✗'
    END as id_format,
    LENGTH(id) as id_length
FROM app.users
LIMIT 5;
