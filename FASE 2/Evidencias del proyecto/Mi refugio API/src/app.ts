import express, { Application } from 'express';
import cors from 'cors';
import routes from './routes';

const app: Application = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Routes
console.log('Cargando rutas...');
app.use('/api', routes);

export default app;
