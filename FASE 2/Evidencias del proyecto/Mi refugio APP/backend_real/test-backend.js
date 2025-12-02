const http = require('http');

const options = {
    hostname: '127.0.0.1',
    port: 3001,
    path: '/api/auth/test',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    }
};

console.log('Testing backend...');

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

req.end();
