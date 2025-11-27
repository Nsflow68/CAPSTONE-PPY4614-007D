export interface AppConfig {
  port: number;
  env: string;
  fastapiBaseUrl: string;
  ollamaBaseUrl: string;
  ollamaModel: string;
  demoUserEmail: string;
  jwtSecret: string;
  jwtExpiresIn: string;
}

export default (): AppConfig => ({
  port: Number(process.env.PORT) || 4000,
  env: process.env.NODE_ENV || 'development',
  fastapiBaseUrl: process.env.FASTAPI_BASE_URL || 'http://localhost:8000',
  ollamaBaseUrl: process.env.OLLAMA_BASE_URL || 'http://localhost:11434',
  ollamaModel: process.env.OLLAMA_MODEL || 'llama3.2:3b-instruct-q4_K_M',
  demoUserEmail: process.env.DEMO_USER_EMAIL || 'invitado@mirefugio.cl',
  jwtSecret: process.env.JWT_SECRET || 'change-me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '1h',
});
