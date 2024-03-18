const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");
const Goal = require("./submitinfo").Goal;
const Category = require("./recipeSubTable").Category;
const Recipe = require("./recipeSubTable").Recipe;

function weightedRandomSampling(weightMap, totalWeights, count) {
  const selectedItems = [];
  let currentWeightMap = [...weightMap];

  for (let i = 0; i < count; i++) {
    let random = Math.random() * totalWeights;
    for (let j = 0; j < currentWeightMap.length; j++) {
      const item = currentWeightMap[j];
      random -= item.weight;
      if (random < 0) {
        selectedItems.push(item.recipe);
        totalWeights -= item.weight;
        currentWeightMap.splice(j, 1);
      }
    }
  }
  return selectedItems;
}

router.get("/", verifyToken, async (req, res) => {
  try {
    const returnType = req.query.returnType || "single";
    const userId = req.auth.userId;
    console.log("User ID:", userId);

    const param = req.query.param;

    let categoryIds;
    switch (param) {
      case "0":
        categoryIds = [2, 4, 10, 15];
        break;
      case "1":
        categoryIds = [1, 2, 3, 4, 5, 8, 9, 10, 12, 15, 16, 17, 18, 20];
        break;
      case "2":
        categoryIds = [11];
        break;
      case "3":
        categoryIds = [14];
        break;
      default:
        categoryIds = [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
          21, 22, 23, 24, 25,
        ];
    }
    function calculateWeight(recipeCalories, userEnergy, userREnergy) {
      const energyLeft = recipeCalories + userREnergy;
      const energyDiff = userEnergy - energyLeft;
      const energyDiffPercentage = energyDiff / userEnergy;

      if (energyDiff >= 0) {
        return 100;
      } else if (energyDiff < 0 && energyDiffPercentage > -0.1) {
        return 100 + energyDiffPercentage * 1000;
      } else {
        return -Infinity;
      }
    }
    function calculateNutrientWeight(recipeNutrient, userGoal, userRGoal) {
      const goalLeft = recipeNutrient + userRGoal;
      const diff = userGoal - goalLeft;
      const diffPercentage = diff / userGoal;

      if (diff >= 0) {
        return 20;
      } else {
        return Math.max(20 + diffPercentage * 200, 0);
      }
    }
    function calculatePotassiumWeight(recipePotassium, userRk) {
      const totalPotassium = recipePotassium + userRk;

      if (totalPotassium <= 3700) {
        return 0;
      } else if (totalPotassium > 3700 && totalPotassium <= 5500) {
        return (-20 * (totalPotassium - 3700)) / (5500 - 3700);
      } else {
        return -Infinity;
      }
    }
    const userGoal = await Goal.findOne({ UID: userId });
    if (!userGoal) {
      return res.status(404).json({ message: "User goal not found." });
    }

    let recipes = await Recipe.find({ categoryId: { $in: categoryIds } }).limit(
      10000
    );
    console.log(recipes);
    recipes = recipes
      .map((recipe) => {
        const energyWeight = calculateWeight(
          recipe.calories,
          userGoal.Energy,
          userGoal.rEnergy
        );
        const fatWeight = calculateNutrientWeight(
          recipe.fat_g,
          userGoal.Fat,
          userGoal.rFat
        );
        const proteinWeight = calculateNutrientWeight(
          recipe.protein_g,
          userGoal.Protein,
          userGoal.rProtein
        );
        const carbWeight = calculateNutrientWeight(
          recipe.carbohydrates_g,
          userGoal.Carbohydrate,
          userGoal.rCarbohydrate
        );
        const potassiumWeight = calculatePotassiumWeight(
          recipe.potassium_mg,
          userGoal.K
        );

        const totalWeight =
          energyWeight +
          fatWeight +
          proteinWeight +
          carbWeight +
          potassiumWeight;

        return { ...recipe._doc, totalWeight };
      })
      .filter((recipe) => recipe.totalWeight !== -Infinity);

    recipes.sort((a, b) => b.totalWeight - a.totalWeight);

    let totalWeights = 0;
    const weightMap = recipes.map((recipe, index) => {
      const weight = 100 - index;
      totalWeights += weight;
      return { recipe, weight };
    });

    const selectedRecipes = weightedRandomSampling(
      weightMap,
      totalWeights,
      100
    );

    if (returnType === "list") {
      res.status(200).json(selectedRecipes);
    } else {
      const randomIndex = Math.floor(Math.random() * selectedRecipes.length);
      const selectedRecipe = selectedRecipes[randomIndex];
      res.status(200).json(selectedRecipe);
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error." });
  }
});

module.exports = router;
