const axios = require('axios');

async function testRegistration() {
    try {
        const response = await axios.post('http://localhost:3001/api/users', {
            username: 'testuser_' + Date.now(),
            email: 'test_' + Date.now() + '@example.com',
            password: 'password123',
            full_name: 'Test User'
        });
        console.log('Registration Success:', response.data);
    } catch (error) {
        if (error.response) {
            console.error('Registration Failed:', error.response.status, error.response.data);
        } else {
            console.error('Registration Error:', error.message);
        }
    }
}

testRegistration();
