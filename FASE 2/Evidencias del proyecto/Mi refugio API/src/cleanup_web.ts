import pool from './config/db';

const cleanupWeb = async () => {
    try {
        console.log('Eliminando tablas antiguas del esquema "web"...');

        await pool.query('DROP TABLE IF EXISTS web.users CASCADE');
        console.log('Tabla web.users eliminada.');

        await pool.query('DROP TABLE IF EXISTS web.chatbot_responses CASCADE');
        console.log('Tabla web.chatbot_responses eliminada.');

    } catch (error) {
        console.error('Error eliminando tablas:', error);
    } finally {
        await pool.end();
    }
};

cleanupWeb();
