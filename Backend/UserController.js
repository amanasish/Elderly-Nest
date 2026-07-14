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


// Get user profile and populated linked users
router.get('/userProfile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { ObjectId } = require('mongodb');

    let userObjectId;
    try {
      userObjectId = new ObjectId(userId);
    } catch (e) {
      return res.status(400).json({ status: 0, message: "Invalid userId format." });
    }

    const db = await dbConnection();
    const users = db.collection("User");

    const user = await users.findOne({ _id: userObjectId });
    if (!user) {
      return res.status(404).json({ status: 0, message: "User not found." });
    }

    // Fetch details of linked users
    let linkedUsersDetails = [];
    if (user.linkedUsers && user.linkedUsers.length > 0) {
      linkedUsersDetails = await users.find(
        { _id: { $in: user.linkedUsers } },
        { projection: { name: 1, email: 1, uniqueCode: 1 } }
      ).toArray();
    }

    res.status(200).json({
      status: 1,
      message: "Profile fetched successfully",
      data: {
        _id: user._id,
        name: user.name,
        email: user.email,
        uniqueCode: user.uniqueCode,
        linkedUsers: linkedUsersDetails
      }
    });

  } catch (error) {
    console.error("Fetch Profile Error:", error);
    res.status(500).json({ status: 0, message: "Internal server error" });
  }
});

// Unlink Caregiver and Elder
router.post('/unlinkUser', async (req, res) => {
  try {
    const { userId, elderId } = req.body;
    const { ObjectId } = require('mongodb');

    if (!userId || !elderId) {
      return res.status(400).json({ status: 0, message: "userId and elderId are required." });
    }

    const db = await dbConnection();
    const users = db.collection("User");

    let caregiverObjectId, elderObjectId;
    try {
      caregiverObjectId = new ObjectId(userId);
      elderObjectId = new ObjectId(elderId);
    } catch (e) {
      return res.status(400).json({ status: 0, message: "Invalid ID format." });
    }

    // Unlink them by pulling each other's ID from their linkedUsers array
    await users.updateOne(
      { _id: caregiverObjectId },
      { $pull: { linkedUsers: elderObjectId } }
    );

    await users.updateOne(
      { _id: elderObjectId },
      { $pull: { linkedUsers: caregiverObjectId } }
    );

    res.status(200).json({
      status: 1,
      message: "User unlinked successfully"
    });
  } catch (error) {
    console.error("Unlink User Error:", error);
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
