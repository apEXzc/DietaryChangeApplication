const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");
const Goal = require("./submitinfo").Goal;

const nutrientMapping = {
  calories: "rEnergy",
  fat_g: "rFat",
  protein_g: "rProtein",
  carbohydrates_g: "rCarbohydrate",
  potassium_mg: "rK",
  cholesterol: "rChol",
  vitamin_a_iu_IU: "rvitaminA",
  vitamin_c_mg: "rvitaminC",
  calcium_mg: "rCa",
  iron_mg: "rFe",
  sodium_mg: "rNa",
};

router.post("/", verifyToken, async (req, res) => {
  const userId = req.auth.userId;
  const { nutritionData } = req.body;

  try {
    console.log(userId, nutritionData);
    const goal = await Goal.findOne({ UID: userId });
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }

    for (const nutrientKey in nutritionData) {
      const goalField = nutrientMapping[nutrientKey];
      if (goalField && goal[goalField] !== undefined) {
        goal[goalField] += nutritionData[nutrientKey];
      }
    }

    await goal.save();
    res.status(200).json({ message: "Food data added successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error updating user goal" });
  }
});

module.exports = router;
