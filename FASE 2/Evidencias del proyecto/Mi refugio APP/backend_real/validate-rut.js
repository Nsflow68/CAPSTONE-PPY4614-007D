function calculateVerifier(rut) {
    let sum = 0;
    let multiplier = 2;

    // Recorrer de derecha a izquierda
    for (let i = rut.length - 1; i >= 0; i--) {
        sum += parseInt(rut[i]) * multiplier;
        multiplier = multiplier === 7 ? 2 : multiplier + 1;
    }

    const remainder = sum % 11;
    const verifier = 11 - remainder;

    if (verifier === 11) return '0';
    if (verifier === 10) return 'K';
    return verifier.toString();
}

// Probar con el RUT del usuario
const rutBody = '20793991';
const correctVerifier = calculateVerifier(rutBody);
console.log(`RUT correcto: ${rutBody}-${correctVerifier}`);

// Verificar si el RUT ingresado es válido
const userVerifier = '9';
console.log(`Verificador ingresado: ${userVerifier}`);
console.log(`Verificador correcto: ${correctVerifier}`);
console.log(`¿Es válido?: ${userVerifier === correctVerifier}`);
