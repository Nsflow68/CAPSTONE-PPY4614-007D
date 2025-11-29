import pool from './config/db';

const createTables = async () => {
    try {
        // Create Schema
        await pool.query('CREATE SCHEMA IF NOT EXISTS app');
        console.log('Esquema app verificado/creado.');

        // Users Table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS app.users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(50) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                full_name VARCHAR(100),
                role VARCHAR(20) DEFAULT 'user'
            );
        `);
        console.log('Tabla users verificada/creada.');

        // Chatbot Responses Table
        await pool.query(`
            CREATE TABLE IF NOT EXISTS app.chatbot_responses (
                id SERIAL PRIMARY KEY,
                keyword VARCHAR(255) UNIQUE NOT NULL,
                response TEXT NOT NULL
            );
        `);
        console.log('Tabla chatbot_responses verificada/creada.');

        // Insert default admin if not exists
        const adminCheck = await pool.query('SELECT * FROM app.users WHERE username = $1', ['admin']);
        if (adminCheck.rows.length === 0) {
            // Note: In a real app, we should hash this password properly on the server side or send it hashed.
            // For now, I'll insert a placeholder or the hash used by the python app if I can replicate it.
            // The python app uses a specific hash function. 
            // Let's just insert a known hash or plain text and handle it in the login logic for now.
            // Wait, the python app sends the password to the auth service. 
            // The API should verify the password.
            // I'll use a simple hash for 'admin123' for now or just plain text if I implement the check.
            // Let's assume the API will handle hashing.

            // For simplicity in this migration, I will just insert the user. 
            // I will implement the login endpoint to compare against this.
            // I'll use a placeholder hash for now.
            await pool.query(`
                INSERT INTO app.users (username, password_hash, role)
                VALUES ('admin', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWrn3ILAWOi/lPa.LSK.X.0.0.0.0', 'admin')
            `);
            console.log('Usuario admin creado.');
        }

    } catch (error) {
        console.error('Error creando tablas:', error);
    } finally {
        await pool.end();
    }
};

createTables();
