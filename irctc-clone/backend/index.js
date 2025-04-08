const express = require("express");
const pool = require("./db");
const cors = require("cors");
const bcrypt = require("bcrypt");
const app = express();

app.use(express.json());
app.use(cors());

app.post("/register", async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Hash the password before storing it
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert into database
        await pool.query(
            "INSERT INTO USERS (Name, Email, Password) VALUES ($1, $2, $3)", 
            [name, email, hashedPassword]
        );

        res.json({ success: true });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

app.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;
        const userResult = await pool.query("SELECT * FROM USERS WHERE Email=$1", [email]);

        if (userResult.rows.length === 0) {
            return res.json({ success: false, message: "User not found" });
        }

        const user = userResult.rows[0];

        // Compare hashed password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.json({ success: false, message: "Invalid credentials" });
        }

        res.json({ success: true, user });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

app.post("/adminLogin", async (req, res) => {
    try {
        const { email, password } = req.body;
        const adminResult = await pool.query("SELECT * FROM ADMIN WHERE Email=$1", [email]);

        if (adminResult.rows.length === 0) {
            return res.json({ success: false, message: "Admin not found" });
        }

        const admin = adminResult.rows[0];

        // Compare hashed password
        const isMatch = await bcrypt.compare(password, admin.password);
        if (!isMatch) {
            return res.json({ success: false, message: "Invalid credentials" });
        }

        res.json({ success: true, admin });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

app.post("/changePasswords", async (req, res) => {
    try {
        const { userId, newPassword } = req.body;

        // Hash the new password
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Update the password in the database
        await pool.query("UPDATE USERS SET Password=$1 WHERE USERID=$2", [hashedPassword, userId]);

        res.json({ success: true, message: "Password updated successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

app.post("/getRoute", async (req, res) => {
    try {
        const { start, end } = req.body;

        // Get station IDs
        const startSt = await pool.query("SELECT StationID FROM STATION WHERE Name=$1", [start]);
        const endSt = await pool.query("SELECT StationID FROM STATION WHERE Name=$1", [end]);

        if (startSt.rows.length === 0 || endSt.rows.length === 0) {
            return res.json({ success: false, message: "No route found" });
        }

        // Get route ID
        const routeResult = await pool.query(
            "SELECT RouteID FROM TRAVERSES WHERE StationID=$1 INTERSECT SELECT RouteID FROM TRAVERSES WHERE StationID=$2", 
            [startSt.rows[0].stationid, endSt.rows[0].stationid]
        );

        if (routeResult.rows.length === 0) {
            return res.json({ success: false, message: "No direct route available" });
        }

        res.json({ success: true, routeId: routeResult.rows[0].routeid });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ success: false, message: "Server error" });
    }
});

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
