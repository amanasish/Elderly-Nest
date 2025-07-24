const bcrypt = require("bcryptjs");
const express = require('express');
const { dbConnection } = require("./config/dbConnection");
const userRoutes = require("../API/UserController.js"); // 👈 Imported controller
const cors = require('cors'); 

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.use("/api", userRoutes); // 👈 Use controller under /api prefix

// Handle 404 - Not Found
app.use((req, res, next) => {
  res.status(404).json({ status: 0, message: "Route not found" });
});

// Handle errors
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ status: 0, message: "Unexpected server error", error: err.message });
});


// Connect to DB and then start server
dbConnection()
  .then(() => {
    console.log("✅ Connected to MongoDB Atlas");
    app.listen(PORT, () => {
      console.log(`🚀 Server running at http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection failed:", err);
  });
