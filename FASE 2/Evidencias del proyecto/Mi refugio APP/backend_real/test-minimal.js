const http = require('http');

// Test with minimal data
const data = JSON.stringify({
    email: "simple@test.com",
    password: "test123",
    name: "Test User",
    rut: "11111111-1",
    username: "testuser"
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

console.log('Testing with minimal data...');
console.log('Data:', data);

const req = http.request(options, res => {
    console.log(`\nStatus Code: ${res.statusCode}`);

    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log('\n=== Response Body ===');
        console.log(body);
    });
});

req.on('error', error => {
    console.error('\n=== Request Error ===');
    console.error(error);
});

req.write(data);
req.end();
