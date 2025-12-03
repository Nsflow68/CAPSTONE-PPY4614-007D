const http = require('http');

const data = JSON.stringify({
    email: "kfv@gmail.com",
    password: "kako123",
    name: "franco",
    rut: "17923602-8",
    username: "franco",
    birthDate: "1999-09-14",
    gender: "Masculino"
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

console.log('Testing registration with franco...');
console.log('Data:', data);

const req = http.request(options, res => {
    console.log(`\nStatus Code: ${res.statusCode}`);

    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log('\n=== Response Body ===');
        console.log(body);
        try {
            const json = JSON.parse(body);
            console.log('\n=== Parsed JSON ===');
            console.log(JSON.stringify(json, null, 2));

            if (json.message) {
                console.log('\n=== Error Message ===');
                console.log(json.message);
            }
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
