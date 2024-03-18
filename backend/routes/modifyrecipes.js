const mongoose = require("mongoose");
const express = require("express");
const router = express.Router();

const SampleRecipeSchema = new mongoose.Schema(
  {
    title: String,
    ingredients: [String],
    directions: [String],
    NER: [String],
  },
  { collection: "sampleRecipe" }
);

const Food = require("./search").Food;
const SampleRecipe = mongoose.model("SampleRecipe", SampleRecipeSchema);

router.get("/", async (req, res) => {
  try {
    const recipes = await SampleRecipe.find();
    for (const recipe of recipes) {
      let fdcIds = [];
      let allMatched = true;

      for (const nerItem of recipe.NER) {
        const cleanedNER = nerItem.replace(/[^a-zA-Z ]/g, "");
        const regex = new RegExp(cleanedNER, "i");
        const foodMatch = await Food.findOne({
          description: { $regex: regex },
        });

        if (foodMatch) {
          fdcIds.push(foodMatch.fdc_id);
        } else {
          allMatched = false;
          break;
        }
      }
      if (allMatched) {
        await SampleRecipe.updateOne(
          { _id: recipe._id },
          { $set: { fdcIds: fdcIds } }
        );
      } else {
        await SampleRecipe.deleteOne({ _id: recipe._id });
      }
    }
    res.send("Recipes have been modified successfully.");
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error during recipe modification.");
  }
});
module.exports = router;
