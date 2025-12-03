const http = require('http');

const data = JSON.stringify({
    email: "marpinto@ug.uchile.cl",
    password: "majo123",
    name: "maria jose pinto",
    rut: "20793991-9",
    username: "marpinto",
    birthDate: "2007-12-22",
    gender: "Femenino"
});

const options = {
    hostname: '127.0.0.1',
    port: 3001,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

console.log('Sending registration request...');
console.log('Data:', data);

const req = http.request(options, res => {
    console.log(`\nStatus Code: ${res.statusCode}`);
    console.log('Headers:', JSON.stringify(res.headers, null, 2));

    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log('\n=== Response Body ===');
        console.log(body);
        try {
            const json = JSON.parse(body);
            console.log('\n=== Parsed JSON ===');
            console.log(JSON.stringify(json, null, 2));
        } catch (e) {
            console.log('Could not parse as JSON');
        }
    });
});

req.on('error', error => {
    console.error('\n=== Request Error ===');
    console.error(error);
});

req.write(data);
req.end();
