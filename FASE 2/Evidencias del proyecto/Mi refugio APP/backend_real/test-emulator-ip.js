const http = require('http');

// Test con la IP del emulador
const data = JSON.stringify({
    email: "kfglv@gmail.com",
    password: "kako123",
    name: "franco",
    rut: "17923602-8",
    username: "francog",
    birthDate: "1999-12-20",
    gender: "Masculino"
});

const options = {
    hostname: '10.0.2.2',  // IP que usa el emulador para localhost
    port: 3001,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

console.log('Testing from emulator perspective (10.0.2.2)...');

const req = http.request(options, res => {
    console.log(`Status Code: ${res.statusCode}`);

    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log('Response:', body);
    });
});

req.on('error', error => {
    console.error('Error:', error);
});

req.write(data);
req.end();
