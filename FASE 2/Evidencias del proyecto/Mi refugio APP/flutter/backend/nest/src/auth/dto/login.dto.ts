import { IsEmail, IsIn, IsOptional, IsString, MinLength } from 'class-validator';

export const AUTH_CLIENTS = ['mobile', 'web', 'desktop'] as const;
export type AuthClient = (typeof AUTH_CLIENTS)[number];

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsOptional()
  @IsIn(AUTH_CLIENTS)
  client?: AuthClient;
}
