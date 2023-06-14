const functions = require("firebase-functions");

const cors = require("cors")({ origin: true });
const { Configuration, PlaidApi, PlaidEnvironments } = require("plaid");

const configuration = new Configuration({
  basePath: PlaidEnvironments.development,
  baseOptions: {
    headers: {
      "PLAID-CLIENT-ID": functions.config().plaid.client_id,
      "PLAID-SECRET": functions.config().plaid.secret,
    },
  },
});
const client = new PlaidApi(configuration);

exports.generateLinkToken = functions.https.onCall(
  async (request, response) => {
    const customerId = response.auth.uid;

    cors(request, response, async () => {
      console.log(request.query);
      //   var client_user_id = ;
      //   var client_name = request.query.client_name;
      await client
        .linkTokenCreate({
          user: {
            client_user_id: functions.config().plaid.client_id,
          },
          client_name: "Reny",
          products: ["auth"],
          country_codes: ["US"],
          language: "en",
        })
        .catch((err) => {
          response.send(err);
        })
        .then((res) => {
          response.send(res.data);
        });
    });
  }
);
