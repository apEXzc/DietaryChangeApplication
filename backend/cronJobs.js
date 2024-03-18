const cron = require("node-cron");
const Goal = require("./routes/submitinfo").Goal;

function generateReport(nutritionIntakes) {
  if (!Array.isArray(nutritionIntakes) || nutritionIntakes.length === 0) {
    return "No nutrition intakes data available for report generation.";
  }

  const accumulator = {
    energy: { total: 0, consumed: 0 },
    fat: { total: 0, consumed: 0 },
    protein: { total: 0, consumed: 0 },
    carbohydrate: { total: 0, consumed: 0 },
    K: { total: 0, consumed: 0 },
    Chol: { total: 0, consumed: 0 },
    vitaminA: { total: 0, consumed: 0 },
    vitaminC: { total: 0, consumed: 0 },
    Ca: { total: 0, consumed: 0 },
    Fe: { total: 0, consumed: 0 },
    Na: { total: 0, consumed: 0 },
  };

  nutritionIntakes.forEach((intake) => {
    Object.keys(accumulator).forEach((nutrient) => {
      if (intake.nutrients[nutrient]) {
        accumulator[nutrient].total += intake.nutrients[nutrient].total;
        accumulator[nutrient].consumed += intake.nutrients[nutrient].remaining;
      }
    });
  });

  let report = "Nutrition Report:\n\n";
  Object.keys(accumulator).forEach((nutrient) => {
    const avgTotal = accumulator[nutrient].total / nutritionIntakes.length;
    const avgConsumed =
      accumulator[nutrient].consumed / nutritionIntakes.length;
    let status = "Good"; // Default status

    if (
      ["energy", "fat", "protein", "carbohydrate", "Chol"].includes(nutrient)
    ) {
      status = avgConsumed < avgTotal ? "Perfect" : "Control Intake";
    } else {
      const diff = avgConsumed - avgTotal;
      const percentageDiff = (diff / avgTotal) * 100;

      if (Math.abs(percentageDiff) <= 5) {
        status = "Perfect";
      } else if (percentageDiff > 10 && percentageDiff <= 20) {
        status = "Control Intake";
      } else if (percentageDiff < -20 || percentageDiff > 20) {
        status = "Consult Professional";
      }
    }

    report += `${
      nutrient.charAt(0).toUpperCase() + nutrient.slice(1)
    }: Total Avg: ${avgTotal.toFixed(2)}, Consumed Avg: ${avgConsumed.toFixed(
      2
    )} - Status: ${status}\n`;
  });

  return report;
}

async function updateAndResetNutritionData() {
  try {
    const goals = await Goal.find({});
    for (const goal of goals) {
      const today = new Date();
      const dailyIntake = {
        date: today,
        nutrients: {
          energy: { total: goal.Energy, remaining: goal.rEnergy },
          fat: { total: goal.Fat, remaining: goal.rFat },
          protein: { total: goal.Protein, remaining: goal.rProtein },
          carbohydrate: {
            total: goal.Carbohydrate,
            remaining: goal.rCarbohydrate,
          },
          K: { total: goal.K, remaining: goal.rK },
          Chol: { total: goal.Chol, remaining: goal.rChol },
          vitaminA: { total: goal.vitaminA, remaining: goal.rvitaminA },
          vitaminC: { total: goal.vitaminC, remaining: goal.rvitaminC },
          Ca: { total: goal.Ca, remaining: goal.rCa },
          Fe: { total: goal.Fe, remaining: goal.rFe },
          Na: { total: goal.Na, remaining: goal.rNa },
        },
      };

      goal.nutritionIntakes.push(dailyIntake);
      goal.weeklyCounter = (goal.weeklyCounter || 0) + 1;
      goal.monthlyCounter = (goal.monthlyCounter || 0) + 1;

      let report = "";

      if (goal.weeklyCounter >= 7) {
        if (goal.weeklyCounter % 7 === 0) {
          report = generateReport(goal.nutritionIntakes.slice(-7));
          goal.lastweekrep = report;
        }
      } else {
        goal.lastweekrep = `Next weekly report in ${
          7 - goal.weeklyCounter
        } days.`;
      }

      if (goal.monthlyCounter >= 28) {
        if (goal.monthlyCounter % 28 === 0) {
          report = generateReport(goal.nutritionIntakes.slice(-28));
          goal.lastmonthrep = report;
        }
      } else {
        goal.lastmonthrep = `Next monthly report in ${
          28 - goal.monthlyCounter
        } days.`;
      }

      Object.keys(goal._doc).forEach((key) => {
        if (key.startsWith("r")) {
          goal[key] = 0;
        }
      });

      await goal.save();
    }
    console.log("Nutrition data and reports updated for all users.");
  } catch (err) {
    console.error("Error during the update and reset process:", err);
  }
}

cron.schedule("59 23 * * *", () => {
  updateAndResetNutritionData()
    .then(() =>
      console.log("Daily nutrition data update and reset task completed.")
    )
    .catch((err) =>
      console.error("Failed to update and reset nutrition data:", err)
    );
});
/*  */
