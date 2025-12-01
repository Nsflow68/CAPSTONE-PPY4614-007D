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
declare const _default: () => AppConfig;
export default _default;
