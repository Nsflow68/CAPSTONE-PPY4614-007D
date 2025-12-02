const http = require('http');

const data = JSON.stringify({
    title: 'Test Node Script',
    content: 'Testing from node script',
    mood: 'Happy',
    score: 8,
    date: new Date().toISOString(),
    emotions: ['joy'],
    tags: ['test']
});

const options = {
    hostname: 'localhost',
    port: 3001,
    path: '/api/diary',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length,
        'Authorization': 'Bearer MmVjMGZiMmEtZDYxOS00YjRmLWExYzctNWNiNzc3NjhmOGU2'
    }
};

const req = http.request(options, (res) => {
    console.log(`STATUS: ${res.statusCode}`);
    console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
        console.log(`BODY: ${chunk}`);
    });
    res.on('end', () => {
        console.log('No more data in response.');
    });
});

req.on('error', (e) => {
    console.error(`problem with request: ${e.message}`);
});

// Write data to request body
req.write(data);
req.end();
