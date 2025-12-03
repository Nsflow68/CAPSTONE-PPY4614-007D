const http = require('http');

const data = JSON.stringify({
    email: "test_debug_9@test.com",
    password: "password123",
    name: "Debug User",
    rut: "1-9",
    username: "debug_user_9"
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

const req = http.request(options, res => {
    console.log(`statusCode: ${res.statusCode}`);
    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log('---BODY_START---');
        console.log(body);
        console.log('---BODY_END---');
    });
});

req.on('error', error => {
    console.error(error);
});

req.write(data);
req.end();
