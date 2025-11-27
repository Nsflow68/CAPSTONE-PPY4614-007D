export declare const AUTH_CLIENTS: readonly ["mobile", "web", "desktop"];
export type AuthClient = (typeof AUTH_CLIENTS)[number];
export declare class LoginDto {
    email: string;
    password: string;
    client?: AuthClient;
}
