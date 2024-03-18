const express = require("express");
const router = express.Router();
const verifyToken = require("../authMiddleware");

app.use(express.json());

app.post("/", verifyToken, (req, res) => {
  console.log(req);
  res.status(200).send("Data received successfully");
});

module.exports = router;
