const mongoose = require("mongoose");
const FoodSchema = new mongoose.Schema(
  {
    description: String,
    fdc_id: Number,
    data_type: String,
  },
  { collection: "food" }
);
const Food = mongoose.model("Food", FoodSchema);
const express = require("express");
const router = express.Router();
router.get("/", async (req, res) => {
  try {
    const searchTerm = req.query.term;
    const searchTerms = searchTerm
      .split(" ")
      .filter((term) => term.trim() !== "");
    const regex = new RegExp(searchTerms.join("|"), "i"); // 修改正则表达式

    let results = await Food.find({
      description: regex,
    });

    const uniqueDescriptionsMap = new Map();
    results.forEach((item) => {
      const descStart = item.description.substring(0, 10);
      if (!uniqueDescriptionsMap.has(descStart)) {
        uniqueDescriptionsMap.set(descStart, item);
      }
    });

    results = Array.from(uniqueDescriptionsMap.values()); // 仅保留唯一的项

    results.sort((a, b) => {
      const aContainsFullPhrase = a.description
        .toLowerCase()
        .includes(searchTerm.toLowerCase());
      const bContainsFullPhrase = b.description
        .toLowerCase()
        .includes(searchTerm.toLowerCase());

      if (aContainsFullPhrase && !bContainsFullPhrase) return -1;
      if (!aContainsFullPhrase && bContainsFullPhrase) return 1;

      const aMatchCount = searchTerms.reduce((count, term) => {
        return count + (a.description.toLowerCase().includes(term) ? 1 : 0);
      }, 0);

      const bMatchCount = searchTerms.reduce((count, term) => {
        return count + (b.description.toLowerCase().includes(term) ? 1 : 0);
      }, 0);

      return bMatchCount - aMatchCount;
    });
    const descriptions = results.map((item) => item.description);
    const fdcIds = results.map((item) => item.fdc_id);
    res.json({ descriptions, fdcIds });
  } catch (err) {
    res.status(500).send("Server error");
  }
});
module.exports = router;
module.exports.Food = Food;
