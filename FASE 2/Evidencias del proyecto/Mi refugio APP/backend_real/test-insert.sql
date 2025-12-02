INSERT INTO app.users (id, email, username, name, password, rut, role, "createdAt", "updatedAt") 
VALUES (gen_random_uuid(), 'sqltest@test.com', 'sqltest', 'SQL Test', 'test123', '55555555-5', 'user', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
RETURNING id, email;
