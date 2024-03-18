const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");

router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.auth.userId;
    const favFoodResult = await FavoriteFood.findOne({ userId });
    const hateFoodResult = await DislikedFood.findOne({ userId });

    const results = [
      favFoodResult ? favFoodResult.foods : [],
      hateFoodResult ? hateFoodResult.foods : [],
    ];
    res.json(results);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

module.exports = router;
