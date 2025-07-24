const express = require('express');
const bcrypt = require("bcryptjs");
const { dbConnection } = require("../src/config/dbConnection"); // adjust path as needed



const User = require("../models/user");

const router = express.Router();

// Sample route

router.get('/', (req, res) => {
  res.send('User route is working!');
});

// Helper to generate random code
function generateRandomCode(length = 12) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let code = '';
  for (let i = 0; i < length; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}


// Check uniqueness of code
async function generateUniqueCode(collection) {
  let code;
  let exists;
  do {
    code = generateRandomCode();
    exists = await collection.findOne({ uniqueCode: code });
  } while (exists);
  return code;
}



// POST /userRegister
router.post("/userRegister", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).send({
        status: 0,
        msg: "Name, email, and password are required.",
      });
    }

    const db = await dbConnection();
    const users = db.collection("User");

    const existing = await users.findOne({ email });
    if (existing) {
      return res.status(409).send({
        status: 0,
        msg: "Email already exists.",
      });
    }

    const uniqueCode = await generateUniqueCode(users);
    const hashedPassword = await bcrypt.hash(password, 10);

    const userObj = {
      name,
      email,
      password: hashedPassword,
      uniqueCode,
    };

    const result = await users.insertOne(userObj);

    res.send({
      status: 1,
      msg: "User Registered Successfully",
      data: {
        _id: result.insertedId,
        name,
        email,
        uniqueCode,
      },
    });

  } catch (err) {
    console.error("Registration Error:", err);
    res.status(500).send({
      status: 0,
      msg: "Registration failed",
      error: err.message,
    });
  }
});


// User login


router.post('/userLogin', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log("Login request received for email:", email);

    const db = await dbConnection();
    const users = db.collection("User");

    const user = await users.findOne({ email });
    if (!user) {
      console.log("User not found");
      return res.status(404).json({ status: 0, message: "User not found" });
    }

    console.log("Entered password:", password);
    console.log("Stored hash:", user.password);

    //for password compare
    const isMatch = await bcrypt.compare(password, user.password);

    console.log("Password match result:", isMatch);

    if (!isMatch) {
      return res.status(401).json({ status: 0, message: "Incorrect password" });
    }

    res.status(200).json({
      status: 1,
      message: "Login successful",
      data: {
        _id: user._id,
        name: user.name,
        email: user.email,
        uniqueCode: user.uniqueCode,
      }
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ status: 0, message: "Internal server error" });
  }
});








module.exports = router;


//old


// api to find the number of objects in my collection of Databases

router.get("/userGetAll",async(req,res)=>{

  //database ban kar isme copy hua
  let myDb = await dbConnection();
  //table creation in DB
  let loginCollection = myDb.collection("User");

  let UserData = await loginCollection.find().toArray();

    res.send({
        status:1,
        msg:"List of Users :",
        UserData
    })
})


// // Insert Into DataBase
// app.post("/user-insert", async (req, res) => {
//   try {
//     const myDb = await dbConnection();
//     console.log("Connected to DB");

//     const loginCollection = myDb.collection("User2"); // change collection here
//     console.log("Collection ready");

//     const obj = {
//       name: req.body.name,
//       email: req.body.email,
//       password: req.body.password,
//     };
//     console.log("Received Object:", obj);

//     const insertRes = await loginCollection.insertOne(obj);
//     console.log("Insert result:", insertRes);

//     res.send({
//       status: 1,
//       msg: "User Inserted!!!",
//       insertRes,
//     });
//   } catch (err) {
//     console.error("Insert Error:", err.message);
//     res.send({
//       status: 0,
//       msg: "Insert failed",
//       error: err.message,
//     });
//   }
// });
