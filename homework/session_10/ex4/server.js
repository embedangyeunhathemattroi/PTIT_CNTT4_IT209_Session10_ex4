const express = require("express");
const { Pool } = require("pg");

const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.DB_HOST || "db-server",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || "appdb",
  port: 5432
});

app.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW() AS time");

    res.json({
      status: "success",
      message: "Backend connected to PostgreSQL",
      database: "db-server",
      time: result.rows[0].time
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      message: error.message
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend running on port ${PORT}`);
});
