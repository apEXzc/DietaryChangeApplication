const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");
const Goal = require("./submitinfo").Goal;

router.get("/", verifyToken, async (req, res) => {
  try {
    const userId = req.auth.userId;
    console.log("User ID:", userId);

    const userGoal = await Goal.findOne({ UID: userId });

    if (!userGoal) {
      return res.status(404).json({ message: "User goal not found." });
    }

    res.status(200).json({
      message: "Nutrition data retrieved successfully.",
      energy: userGoal.Energy || 0,
      rEnergy: userGoal.rEnergy || 0,
      Fat: userGoal.Fat || 0,
      rFat: userGoal.rFat || 0,
      Protein: userGoal.Protein || 0,
      rProtein: userGoal.rProtein || 0,
      Carbohydrate: userGoal.Carbohydrate || 0,
      rCarbohydrate: userGoal.rCarbohydrate || 0,
      vitaminA: userGoal.vitaminA || 0,
      rvitaminA: userGoal.rvitaminA || 0,
      vitaminC: userGoal.vitaminC || 0,
      rvitaminC: userGoal.rvitaminC || 0,
      Na: userGoal.Na || 0,
      rNa: userGoal.rNa || 0,
      Ca: userGoal.Ca || 0,
      rCa: userGoal.rCa || 0,
      Fe: userGoal.Fe || 0,
      rFe: userGoal.rFe || 0,
      K: userGoal.K || 0,
      rK: userGoal.rK || 0,
      Chol: userGoal.Chol || 0,
      rChol: 0,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error." });
  }
});

module.exports = router;
