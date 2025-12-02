class RutValidator {
    static clean(rut) {
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

    static validate(rut) {
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

    static calculateVerifier(digits) {
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
}

// Test con el RUT del usuario
const userRut = "20793991-9";
console.log('RUT original:', userRut);

const cleaned = RutValidator.clean(userRut);
console.log('RUT limpio:', cleaned);

const isValid = RutValidator.validate(cleaned);
console.log('¿Es válido?:', isValid);
