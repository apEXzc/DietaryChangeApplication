const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");
const Goal = require("./submitinfo").Goal;

const nutrientMapping = {
  "Energy(Kcal = mg*4)": "rEnergy",
  "Fat(g)": "rFat",
  "Protein(g)": "rProtein",
  "Carbohydrate(g)": "rCarbohydrate",
  "Potassium(mg)": "rK",
  "Cholesterol(mg)": "rChol",
  "vitaminA(IU = 1000*mg)": "rvitaminA",
  "vitaminC(mg)": "rvitaminC",
  "Calcium(mg)": "rCa",
  "Iron(mg)": "rFe",
  "Sodium(mg)": "rNa",
};

router.post("/", verifyToken, async (req, res) => {
  const userId = req.auth.userId;
  const { foodName, mealType, nutrients } = req.body;

  try {
    const goal = await Goal.findOne({ UID: userId });
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }

    for (const nutrientKey in nutrients) {
      const goalField = nutrientMapping[nutrientKey];
      if (goalField && goal[goalField] !== undefined) {
        goal[goalField] += nutrients[nutrientKey];
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
