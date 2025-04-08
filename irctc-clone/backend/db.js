const mysql = require("mysql2");

const pool = mysql.createPool({
    host: "localhost",    // Change if using a different host
    user: "your_mysql_user",
    password: "your_mysql_password",
    database: "your_database_name",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Export promise-based pool for async/await support
const promisePool = pool.promise();
module.exports = promisePool;
