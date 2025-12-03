import * as pbkdf2 from 'pbkdf2';

export class PasswordUtil {
    /**
     * Verifies a password against a Django pbkdf2_sha256 hash.
     * Format: pbkdf2_sha256$iterations$salt$hash
     */
    static verifyDjangoPassword(password: string, djangoHash: string): boolean {
        const parts = djangoHash.split('$');
        if (parts.length !== 4) return false;

        const [algorithm, iterationsStr, salt, hash] = parts;
        const iterations = parseInt(iterationsStr, 10);

        if (algorithm !== 'pbkdf2_sha256') return false;

        const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
        const derivedKeyBase64 = derivedKey.toString('base64');

        return derivedKeyBase64 === hash;
    }

    static hashDjangoPassword(password: string): string {
        const iterations = 216000;
        const salt = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
        const hash = derivedKey.toString('base64');
        return `pbkdf2_sha256$${iterations}$${salt}$${hash}`;
    }
}
