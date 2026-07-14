const express = require('express');
const bcrypt = require("bcryptjs");
const { dbConnection } = require("./dbConnection"); // adjust path as needed



const User = require("./user");

const router = express.Router();

// Sample route

router.get('/', (req, res) => {
  res.send('User route is working! (v2)');
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

// Link Caregiver and Elder using Elder's uniqueCode
router.post('/linkUser', async (req, res) => {
  try {
    const { userId, uniqueCode } = req.body;
    const { ObjectId } = require('mongodb');

    if (!userId || !uniqueCode) {
      return res.status(400).json({ status: 0, message: "userId and uniqueCode are required." });
    }

    const db = await dbConnection();
    const users = db.collection("User");

    // 1. Find the elder user by uniqueCode
    const elder = await users.findOne({ uniqueCode: uniqueCode });
    if (!elder) {
      return res.status(404).json({ status: 0, message: "User with this unique code not found." });
    }

    // 2. Find the caregiver user by userId
    let caregiverObjectId;
    try {
      caregiverObjectId = new ObjectId(userId);
    } catch (e) {
      return res.status(400).json({ status: 0, message: "Invalid userId format." });
    }

    const caregiver = await users.findOne({ _id: caregiverObjectId });
    if (!caregiver) {
      return res.status(404).json({ status: 0, message: "Caregiver user not found." });
    }

    // Check if already linked
    const alreadyLinked = caregiver.linkedUsers && caregiver.linkedUsers.some(id => id.toString() === elder._id.toString());
    if (alreadyLinked) {
      return res.status(400).json({ status: 0, message: "Users are already linked." });
    }

    // 3. Link them by pushing each other's ID to their linkedUsers array
    await users.updateOne(
      { _id: caregiverObjectId },
      { $addToSet: { linkedUsers: elder._id } }
    );

    await users.updateOne(
      { _id: elder._id },
      { $addToSet: { linkedUsers: caregiverObjectId } }
    );

    res.status(200).json({
      status: 1,
      message: "Users linked successfully",
      data: {
        caregiverId: caregiver._id,
        elderId: elder._id,
        elderName: elder.name,
        elderEmail: elder.email
      }
    });
  } catch (error) {
    console.error("Link User Error:", error);
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
