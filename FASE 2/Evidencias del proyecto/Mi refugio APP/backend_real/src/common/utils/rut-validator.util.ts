export class RutValidator {
    /**
     * Valida un RUT chileno
     * Acepta formatos: 12345678-9, 12.345.678-9
     */
    static validate(rut: string): boolean {
        if (!rut || typeof rut !== 'string') {
            return false;
        }

        // Limpiar el RUT (quitar puntos y espacios)
        const cleanRut = rut.replace(/\./g, '').replace(/\s/g, '').toUpperCase();

        // Verificar formato básico (7-8 dígitos, guion, dígito o K)
        const rutPattern = /^(\d{7,8})-([0-9K])$/;
        const match = cleanRut.match(rutPattern);

        if (!match) {
            return false;
        }

        const [, digits, verifier] = match;

        // Calcular dígito verificador usando módulo 11
        const calculatedVerifier = this.calculateVerifier(digits);

        return calculatedVerifier === verifier;
    }

    /**
     * Calcula el dígito verificador de un RUT
     */
    private static calculateVerifier(digits: string): string {
        let sum = 0;
        let multiplier = 2;

        // Recorrer de derecha a izquierda
        for (let i = digits.length - 1; i >= 0; i--) {
            sum += parseInt(digits[i]) * multiplier;
            multiplier = multiplier === 7 ? 2 : multiplier + 1;
        }

        const remainder = sum % 11;
        const verifier = 11 - remainder;

        if (verifier === 11) return '0';
        if (verifier === 10) return 'K';
        return verifier.toString();
    }

    /**
     * Formatea un RUT al formato estándar XX.XXX.XXX-X
     */
    static format(rut: string): string {
        if (!rut) return '';

        // Limpiar el RUT
        const cleanRut = rut.replace(/\./g, '').replace(/\s/g, '').replace(/-/g, '').toUpperCase();

        // Separar dígitos y verificador
        const verifier = cleanRut.slice(-1);
        const digits = cleanRut.slice(0, -1);

        // Formatear con puntos
        const formattedDigits = digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.');

        return `${formattedDigits}-${verifier}`;
    }

    /**
     * Limpia un RUT dejando solo el formato XXXXXXXX-X
     */
    static clean(rut: string): string {
        if (!rut) return '';

        const cleanRut = rut.replace(/\./g, '').replace(/\s/g, '').toUpperCase();

        // Verificar que tenga el guion
        if (!cleanRut.includes('-')) {
            // Si no tiene guion, asumimos que el último carácter es el verificador
            const verifier = cleanRut.slice(-1);
            const digits = cleanRut.slice(0, -1);
            return `${digits}-${verifier}`;
        }

        return cleanRut;
    }
}
