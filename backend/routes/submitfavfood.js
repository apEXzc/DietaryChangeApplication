const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");

const mongoose = require("mongoose");
const favoriteFoodSchema = new mongoose.Schema({
  userId: { type: Number, required: true, unique: true, index: true },
  foods: [String],
});
const FavoriteFood = mongoose.model("FavoriteFood", favoriteFoodSchema);

const dislikedFoodSchema = new mongoose.Schema({
  userId: { type: Number, required: true, unique: true, index: true },
  foods: [String],
});
const DislikedFood = mongoose.model("DislikedFood", dislikedFoodSchema);

router.post("/", verifyToken, async (req, res) => {
  try {
    const userId = req.auth.userId;
    const { favoriteFoods, dislikedFoods } = req.body;

    await FavoriteFood.findOneAndUpdate(
      { userId },
      { userId, foods: favoriteFoods },
      { upsert: true, new: true }
    );

    await DislikedFood.findOneAndUpdate(
      { userId },
      { userId, foods: dislikedFoods },
      { upsert: true, new: true }
    );

    res.status(200).send("Data saved successfully");
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

router.get("/foodlist", verifyToken, async (req, res) => {
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
