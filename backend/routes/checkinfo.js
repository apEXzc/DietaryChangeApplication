const express = require("express");
const bcrypt = require("bcrypt");
const User = require("./submitinfo").User;
const router = express.Router();
const jwt = require("jsonwebtoken");

router.post("/", async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ emailaddress: username });
    if (!user) {
      return res.status(404).json({ message: "Please check your email." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Incorrect password." });
    }
    const token = jwt.sign(
      { userId: user.UID },
      "PViuRxdKMqfDPoILBgkvWvtEsDZNBrHRgJBDoyqZbJT",
      {
        expiresIn: "1h",
      }
    );
    res.status(200).json({ token, message: "Login successful." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error." });
  }
});

module.exports = router;
