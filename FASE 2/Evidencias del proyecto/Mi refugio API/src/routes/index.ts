import { Router } from 'express';
import pool from '../config/db';
import authRoutes from './auth';
import chatbotRoutes from './chatbot';
import userRoutes from './users';
import resourceRoutes from './resources';

const router = Router();

console.log('Cargando rutas...');
router.use('/auth', authRoutes);
router.use('/chatbot', chatbotRoutes);
router.use('/users', userRoutes);
router.use('/resources', resourceRoutes);

router.get('/health', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW()');
        res.json({
            status: 'OK',
            message: 'API funcionando correctamente',
            db_time: result.rows[0].now
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'ERROR', message: 'Error de conexión a la base de datos' });
    }
});

export default router;
