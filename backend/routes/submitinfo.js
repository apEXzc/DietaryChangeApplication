const mongoose = require("mongoose");
const { Schema } = mongoose;
const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const saltRounds = 10;

function calculateNutrients(age, gender) {
  const potassium = gender === "Male" ? 3400 : 2600;
  const calcium = age > 50 ? 1200 : 1000;
  const vitaminA = gender === "Male" ? 2997 : 2331;
  const vitaminC = gender === "Male" ? 90 : 75;
  const iron = gender === "Male" ? 8 : age > 50 ? 8 : 18;
  const max_cholesterolLimit = 300;
  const Na = age > 18 ? 1800 : 2500;
  return {
    potassium,
    calcium,
    vitaminA,
    vitaminC,
    iron,
    max_cholesterolLimit,
    Na,
  };
}

const userSchema = new Schema(
  {
    firstname: { type: String, required: true },
    lastname: { type: String, required: true },
    emailaddress: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    UID: { type: Number, required: true, unique: true },
  },
  { collection: "Token" }
);

const User = mongoose.model("User", userSchema, "Tokens");

const nutrientSchema = new mongoose.Schema({
  energy: { total: Number, remaining: Number },
  fat: { total: Number, remaining: Number },
  protein: { total: Number, remaining: Number },
  carbohydrate: { total: Number, remaining: Number },
  K: { total: Number, remaining: Number },
  Chol: { total: Number, remaining: Number },
  vitaminA: { total: Number, remaining: Number },
  vitaminC: { total: Number, remaining: Number },
  Ca: { total: Number, remaining: Number },
  Fe: { total: Number, remaining: Number },
  Na: { total: Number, remaining: Number },
});

const nutritionIntakeSchema = new mongoose.Schema({
  date: { type: Date, default: Date.now },
  nutrients: nutrientSchema,
});

const goalSchema = new Schema(
  {
    UID: { type: Number, required: true, unique: true },
    Age: { type: Number, required: true },
    Sex: { type: String, required: true },
    Height: { type: Number, required: true },
    Weight: { type: Number, required: true },
    disease: { type: [String], required: true },
    diettype: { type: [String], required: true },
    exercise: { type: [String], required: true },
    purpose: { type: [String], required: true },
    BMR: { type: Number, required: true },
    Energy: { type: Number, required: true },
    rEnergy: { type: Number, required: true },
    Fat: { type: Number, required: true },
    rFat: { type: Number, required: true },
    Protein: { type: Number, required: true },
    rProtein: { type: Number, required: true },
    Carbohydrate: { type: Number, required: true },
    rCarbohydrate: { type: Number, required: true },
    K: { type: Number, required: true },
    rK: { type: Number, required: true },
    Chol: { type: Number, required: true },
    rChol: { type: Number, required: true },
    vitaminA: { type: Number, required: true },
    rvitaminA: { type: Number, required: true },
    vitaminC: { type: Number, required: true },
    rvitaminC: { type: Number, required: true },
    Ca: { type: Number, required: true },
    rCa: { type: Number, required: true },
    Fe: { type: Number, required: true },
    rFe: { type: Number, required: true },
    Na: { type: Number, required: true },
    rNa: { type: Number, required: true },
    nutritionIntakes: [nutritionIntakeSchema],
    weeklyCounter: { type: Number, default: 0 },
    monthlyCounter: { type: Number, default: 0 },
    lastweekrep: { type: String, default: "Next weekly report in 7 days." },
    lastmonthrep: { type: String, default: "Next monthly report in 28 days." },
  },
  { collection: "Goal" }
);

const CounterSchema = new Schema({
  _id: { type: String, required: true },
  seq: { type: Number, default: 1 },
});

const Counter = mongoose.model("Counter", CounterSchema);

async function initializeCounter() {
  try {
    const counter = await Counter.findById("uid");
    if (!counter) {
      await Counter.create({ _id: "uid", seq: 1 });
    }
  } catch (err) {
    console.error("Error initializing counter:", err);
  }
}
initializeCounter();

async function getNextUID() {
  const counter = await Counter.findOneAndUpdate(
    { _id: "uid" },
    { $inc: { seq: 1 } },
    { new: true, upsert: true }
  );
  return counter.seq;
}
const Goal = mongoose.model("Goal", goalSchema, "Goals");

router.post("/", async (req, res) => {
  const { firstname, lastname, email, password, answers } = req.body;
  const nutrients = calculateNutrients(parseInt(answers["0"]), answers["1"]);
  console.log(answers);
  try {
    const uid = await getNextUID();
    const existingUser = await User.findOne({ emailaddress: email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already in use" });
    }
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const newUser = new User({
      firstname,
      lastname,
      emailaddress: email,
      password: hashedPassword,
      UID: uid,
    });

    await newUser.save();

    if (answers) {
      let BMR;

      if (answers["1"].trim() === "Male") {
        BMR =
          88.362 +
          13.397 * parseInt(answers["3"]) +
          4.799 * parseInt(answers["2"]) -
          5.677 * parseInt(answers["0"]);
      } else {
        BMR =
          447.593 +
          9.247 * parseInt(answers["3"]) +
          3.098 * parseInt(answers["2"]) -
          4.33 * parseInt(answers["0"]);
      }
      let activityFactor;
      switch (answers["6"]) {
        case "5 days or more":
          activityFactor = 1.2;
          break;
        case "3-5 days":
          activityFactor = 1.375;
          break;
        case "1-3 days":
          activityFactor = 1.55;
          break;
        case "Everyday / heavy physical exercise":
          activityFactor = 1.725;
          break;
        default:
          activityFactor = 1.9;
      }
      const newGoal = new Goal({
        UID: uid,
        Age: parseInt(answers["0"]),
        Sex: answers["1"],
        Height: parseInt(answers["2"]),
        Weight: parseInt(answers["3"]),
        disease: answers["4"],
        diettype: answers["5"],
        purpose: answers["6"],
        exercise: answers["7"],
        BMR: BMR,
        Energy: BMR * activityFactor,
        rEnergy: 0,
        Fat: (BMR * activityFactor * 0.25) / 4,
        rFat: 0,
        Protein: (BMR * activityFactor * 0.2) / 4,
        rProtein: 0,
        Carbohydrate: (BMR * activityFactor * 0.45) / 4,
        rCarbohydrate: 0,
        vitaminA: nutrients.vitaminA,
        rvitaminA: 0,
        vitaminC: nutrients.vitaminC,
        rvitaminC: 0,
        Ca: nutrients.calcium,
        rCa: 0,
        Fe: nutrients.iron,
        rFe: 0,
        K: nutrients.potassium,
        rK: 0,
        Chol: nutrients.max_cholesterolLimit,
        rChol: 0,
        Na: nutrients.Na,
        rNa: 0,
      });
      await newGoal.save();
    }
    res.status(200).json({ message: "Registration successful" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error registering user" });
  }
});

module.exports = router;
module.exports.User = User;
module.exports.Goal = Goal;
