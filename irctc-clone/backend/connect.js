import mysql from 'mysql2/promise';

// Database configuration
const pool = mysql.createPool({
  host: 'localhost', // Change if necessary
  user: 'your_username',
  password: 'your_password',
  database: 'your_database',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

export default pool;
