const functions = require("firebase-functions");
const express = require("express");
const { default: axios } = require("axios");
const app = express();

const clientid = functions.config().plaid.client_id;
const secret = functions.config().plaid.secret;
const plaid_api_base_url = "https://developer.plaid.com";
const plaid_endpoint = `${plaid_api_base_url}/link/token/create`;

exports.createPlaidLinkToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called " + "while authenticated."
    );
  }

  const customerId = context.auth.uid;

  // it's all("*") meant only for testing
  app.all("*", async (req, res) => {
    try {
      const respnse = await axios.post(plaid_endpoint, {
        client_id: clientid,
        secret: secret,
        client_name: "Reny",
        country_codes: ["US"],
        language: "en",
        user: {
          client_user_id: customerId,
        },
        products: ["auth"],
      });
      return res.json(respnse.data);
    } catch (e) {
      console.log(e);
    }
    return res.json({}); // If things don't go well it returns an empty response
  });

  exports.app = functions.https.onRequest(app);
});
