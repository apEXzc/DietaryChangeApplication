const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");
const Goal = require("./submitinfo").Goal;

router.get("/weekly", verifyToken, async (req, res) => {
  try {
    const userId = req.auth.userId;
    const goal = await Goal.findOne({ UID: userId });

    if (goal && goal.lastweekrep) {
      res.json({ report: goal.lastweekrep });
    } else {
      res.status(404).json({ message: "Weekly report not found." });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/monthly", verifyToken, async (req, res) => {
  try {
    const userId = req.auth.userId;
    const goal = await Goal.findOne({ UID: userId });

    if (goal && goal.lastmonthrep) {
      res.json({ report: goal.lastmonthrep });
    } else {
      res.status(404).json({ message: "Monthly report not found." });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
