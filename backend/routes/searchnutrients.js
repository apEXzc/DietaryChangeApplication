const mongoose = require("mongoose");
const redisClient = require("../redisClient");
const FoodNutrientSchema = new mongoose.Schema(
  {
    fdc_id: Number,
    nutrient_id: Number,
    amount: Number,
    data_points: Number,
    derivation_id: Number,
  },
  { collection: "food_nutrient" }
);

const NutrientSchema = new mongoose.Schema(
  {
    id: Number,
    name: String,
    unit_name: String,
    nutrient_nbr: Number,
  },
  { collection: "nutrient" }
);
const express = require("express");
const router = express.Router();

const Food = require("./search").Food;
const FoodNutrient = mongoose.model("FoodNutrient", FoodNutrientSchema);
const Nutrient = mongoose.model("Nutrient", NutrientSchema);

router.get("/", async (req, res) => {
  try {
    const foodName = req.query.foodName;
    const foods = await Food.find({ description: new RegExp(foodName, "i") });

    if (!foods.length) {
      return res.status(404).send("Food not found");
    }

    let nutrientsArray = [];
    for (let food of foods) {
      const foodNutrients = await FoodNutrient.find({ fdc_id: food.fdc_id });

      for (let foodNutrient of foodNutrients) {
        const nutrient = await Nutrient.findOne({
          id: foodNutrient.nutrient_id,
        });
        if (nutrient) {
          nutrientsArray.push({
            foodDescription: food.description,
            name: nutrient.name,
            amount: foodNutrient.amount,
            unit: nutrient.unit_name,
          });
        }
      }
    }

    res.json(nutrientsArray);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

module.exports = router;
