const createError = require("http-errors");
const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
const cors = require("cors");

const modifyRecipesRouter = require("./routes/modifyrecipes");
const indexRouter = require("./routes/index");
const usersRouter = require("./routes/users");
const searchRouter = require("./routes/search");
const getNutrientRouter = require("./routes/searchnutrients");
const submitinfo = require("./routes/submitinfo");
const login = require("./routes/checkinfo");
const updatePage = require("./routes/updatepage");
const subfavfood = require("./routes/submitfavfood");
const foodlist = require("./routes/foodlist");
const updatePersonalData = require("./routes/showdata");
const categorizeRecipes = require("./routes/recipeSubTable");
const recomsys = require("./routes/recomsys");
const updatedata = require("./routes/updatedata");
const modifydata = require("./routes/modifydata");
const report = require("./routes/report");
const app = express();

require("./cronJobs");

app.use(cors());

const mongoose = require("mongoose");

mongoose
  .connect("mongodb://localhost:27017/SimpleNutrientDatabase")
  .then(() => {
    console.log("Database connection successful");
  })
  .catch((err) => {
    console.error("Database connection error:", err);
  });

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "jade");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use("/", indexRouter);
app.use("/users", usersRouter);
app.use("/search", searchRouter);
app.use("/searchnutrients", getNutrientRouter);
app.use("/submitreginfo", submitinfo);
app.use("/login", login);
app.use("/modify", modifyRecipesRouter);
app.use("/updatepage", updatePage);
app.use("/submitfav", subfavfood);
app.use("/foodlist", foodlist);
app.use("/userupnutrition", updatePersonalData);
app.use("/categorize-recipes", categorizeRecipes);
app.use("/recomsys", recomsys);
app.use("/updatedata", updatedata);
app.use("/modifydata", modifydata);
app.use("/report", report);
app.use(function (req, res, next) {
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
