const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const RecipeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    category: { type: String, required: true },
    summary: { type: String, required: true },
    ingredients: { type: String, required: true },
    directions: { type: String, required: true },
    calories: { type: Number, required: true },
    protein_g: { type: Number, required: true, default: 0 },
    carbohydrates_g: { type: Number, required: true, default: 0 },
    fat_g: { type: Number, required: true, default: 0 },
    cholesterol_mg: { type: Number, required: true, default: 0 },
    sodium_mg: { type: Number, required: true, default: 0 },
    calcium_mg: { type: Number, required: true, default: 0 },
    iron_mg: { type: Number, required: true, default: 0 },
    potassium_mg: { type: Number, required: true, default: 0 },
    vitamin_a_iu_IU: { type: Number, required: true, default: 0 },
    vitamin_c_mg: { type: Number, required: true, default: 0 },
    categoryId: { type: Number, required: true },
    index: { type: Number, required: true },
  },
  { collection: "recipe2" }
);
const Recipe = mongoose.model("Recipe", RecipeSchema);
const CategorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  categoryId: { type: Number, required: true, unique: true, index: true },
});
const Category = mongoose.model("Category", CategorySchema);
async function getNextCategoryId() {
  const lastCategory = await Category.findOne().sort({ categoryId: -1 });
  if (lastCategory) return lastCategory.categoryId + 1;
  return 1;
}

router.get("/", async (req, res) => {
  try {
    const recipes = await Recipe.find({});
    for (const recipe of recipes) {
      let category = await Category.findOne({ name: recipe.category });
      if (!category) {
        const categoryId = await getNextCategoryId();
        category = await Category.create({ name: recipe.category, categoryId });
      }
      recipe.categoryId = category.categoryId;
      await recipe.save();
    }
    res.send("Recipes have been categorized.");
  } catch (error) {
    console.error("Error categorizing recipes:", error);
    res.status(500).send("Server error");
  }
});

router.get("/add-recipe-index", async (req, res) => {
  try {
    let currentIndex = 1;
    const recipes = await Recipe.find({}).sort({ _id: 1 });

    for (const recipe of recipes) {
      recipe.index = currentIndex;
      await recipe.save();
      currentIndex++;
    }

    res.send("Successful");
  } catch (error) {
    console.error("Error updating recipes:", error);
    res.status(500).send("Server error");
  }
});

router.get("/remove-no-calories", async (req, res) => {
  try {
    const result = await Recipe.deleteMany({ calories: { $exists: false } });
    res.send(`Deleted ${result.deletedCount} items.`);
  } catch (error) {
    console.error("Error deleting recipes without calories:", error);
    res.status(500).send("Server error");
  }
});

module.exports = router;
module.exports.Recipe = Recipe;
module.exports.Category = Category;
