// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
//<script src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"></script>;

// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage().bucket();
const auth = admin.auth;

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
exports.addMessage = functions.https.onRequest(async (req, res) => {
  // Grab the text parameter.
  const original = req.query.text;
  // Push the new message into Firestore using the Firebase Admin SDK.
  const writeResult = await admin
    .firestore()
    .collection("messages")
    .add({ original: original });
  // Send back a message that we've successfully written the message
  res.json({ result: "Message with ID: ${writeResult.id} added." });
});

//delete use function
exports.deleteUser = functions.https.onRequest(async (request, response) => {
  const email = request.body.email;

  //await is wait for the async function to finish itchb!
  const user = await auth.getUserByEmail(email).catch((error) => {
    console.log(error);
    response.status(500).send("Unable to get user", error);
  });

  auth
    .deleteUser(user.uid)
    .then(() => {
      //THEN is closure when things go according to plan
      response.status(200).send("User succesfully deleted");
    })
    .catch((error) => {
      response.status(500).send("error attempting to delete the user", error);
    });
});

//PLAID - create link Token plaid Nat
const plaid = require("plaid");

exports.createPlaidLinkToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called " + "while authenticated."
    );
  }

  const customerId = context.auth.uid;

  const plaidClient = new plaid.Client({
    clientID: functions.config().plaid.client_id,
    secret: functions.config().plaid.secret,
    //env: plaid.environments.sandbox,
    // options: {
    //   version: "2019-05-29",
    // },
  });

  return plaidClient
    .createLinkToken({
      user: {
        client_user_id: customerId,
      },
      client_name: "Reny",
      products: [development.auth],
      country_codes: ["US"],
      language: "en",
    })
    .then((apiResponse) => {
      const linkToken = apiResponse.link_token;
      return linkToken;
    })
    .catch((err) => {
      console.log(err);
      throw new functions.https.HttpsError(
        "internal",
        " Unable to create plaid link token: " + err
      );
    });
});
