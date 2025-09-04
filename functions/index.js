const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.telegramWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const update = req.body;
    const message = update.message || update.channel_post;

    if (!message || !message.text) {
      console.log("No valid message text found.");
      return res.status(200).send("OK");
    }
    const messageText = message.text;

    // --- تحليل الرسالة باستخدام التعبيرات النمطية ---
    const pairMatch = messageText.match(/💳\s*([^\s\n]+)/);
    const timeframeMatch = messageText.match(/🔥\s*([^\s\n]+)/);
    const entryTimeMatch = messageText.match(/⌛️\s*([^\s\n]+)/);
    const directionMatch = messageText.match(/🔽\s*([^\s\n]+)/i) || messageText.match(/🔼\s*([^\s\n]+)/i); // للتعامل مع call/put
    const forecastMatch = messageText.match(/📈\s*Forecast:\s*([\d.]+)%/);
    const payoutMatch = messageText.match(/💸\s*Payout:\s*([\d.]+)%/);

    // إذا لم يتم العثور على البيانات الأساسية، تجاهل الرسالة
    if (!pairMatch || !timeframeMatch || !entryTimeMatch || !directionMatch) {
        console.log("Essential data not found in message. Ignoring.");
        return res.status(200).send("OK");
    }

    const pair = pairMatch[1];
    const timeframe = timeframeMatch[1];
    const entryTime = entryTimeMatch[1];
    const direction = directionMatch[1];
    const forecast = forecastMatch ? forecastMatch[1] : null;
    const payout = payoutMatch ? payoutMatch[1] : null;
    // ----------------------------------------------------

    // --- حفظ البيانات الجديدة في Firestore ---
    await db.collection("recommendations").add({
      pair: pair,
      direction: direction,
      timeframe: timeframe,
      entryTime: entryTime,
      forecast: forecast,
      payout: payout,
      status: "نشطة", // Status will be updated later
      result: null, // Result will be updated later
      isVip: true, // Assuming these are VIP signals
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    // ------------------------------------------

    console.log("Successfully parsed and added rich recommendation:", pair);
    return res.status(200).send("OK");
  } catch (error) {
    console.error("Error processing message:", error);
    return res.status(500).send("Internal Server Error");
  }
});