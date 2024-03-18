const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");

router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.userId;
    console.log("User ID:", userId);
    res
      .status(200)
      .json({ message: "User ID retrieved successfully.", userId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error." });
  }
});

module.exports = router;
