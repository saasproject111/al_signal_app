const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// لازم تكون مسجل المفتاح كده:
// firebase functions:config:set nowpayments.key="YOUR_API_KEY"
const NOWPAYMENTS_API_KEY = functions.config().nowpayments.key;

// دالة مساعدة مشتركة لعمل الفاتورة
async function createInvoice({ amount, plan, userId, ipnUrl }) {
  const payload = {
    price_amount: amount,               // سعر بالدولار
    price_currency: "usd",
    pay_currency: "usdttrc20",          // USDT على شبكة TRON (غيّرها لو عايز)
    order_id: `${userId || "anon"}_${Date.now()}`,
    order_description: `Subscription for ${plan || "usdt"}`,
    ipn_callback_url: ipnUrl,           // رابط الويب هوك بتاعك
    // تقدر تضيف success_url / cancel_url لو عايز تمسك الرجوع في الواجهة
  };

  const { data } = await axios.post(
    "https://api.nowpayments.io/v1/invoice",
    payload,
    {
      headers: {
        "x-api-key": NOWPAYMENTS_API_KEY,
        "Content-Type": "application/json",
      },
    }
  );

  if (!data?.invoice_url) {
    throw new Error(`NOWPayments did not return invoice_url: ${JSON.stringify(data)}`);
  }
  return data.invoice_url;
}

// ========== 1) Callable للـ Flutter ==========
exports.createNowPaymentsInvoice = functions
  .region("us-central1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login required.");
    }

    const amount = Number(data?.price);
    const plan = data?.plan || "usdt";

    if (!amount || Number.isNaN(amount)) {
      throw new functions.https.HttpsError("invalid-argument", "Valid 'price' is required.");
    }

    try {
      const ipnUrl = "https://nowpaymentswebhook-xbg5nturcq-uc.a.run.app"; // <- بتاعك
      const paymentUrl = await createInvoice({
        amount,
        plan,
        userId: context.auth.uid,
        ipnUrl,
      });
      return { paymentUrl };
    } catch (err) {
      console.error("createNowPaymentsInvoice error:", err.response?.data || err.message);
      throw new functions.https.HttpsError("internal", "Could not create payment invoice.");
    }
  });

// ========== 2) HTTP للاختبار (اختياري) ==========
exports.createNowPaymentsInvoiceHttp = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    try {
      const amount = Number(req.body?.amount || req.query.amount);
      const plan = req.body?.plan || req.query.plan || "usdt";
      const userId = req.body?.userId || req.query.userId || "anon";

      if (!amount || Number.isNaN(amount)) {
        return res.status(400).json({ error: "amount is required" });
      }

      const ipnUrl = "https://nowpaymentswebhook-xbg5nturcq-uc.a.run.app"; // <- بتاعك
      const paymentUrl = await createInvoice({ amount, plan, userId, ipnUrl });
      res.json({ invoice_url: paymentUrl });
    } catch (err) {
      console.error("createNowPaymentsInvoiceHttp error:", err.response?.data || err.message);
      res.status(500).json({ error: err.response?.data || err.message });
    }
  });

// ========== 3) Webhook لتفعيل الـ VIP ==========
exports.nowPaymentsWebhook = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    try {
      // TODO: للتحقق الأمني الحقيقي استخدم x-nowpayments-sig + IPN secret
      const paymentStatus = req.body?.payment_status;
      const orderId = req.body?.order_id || "";
      const userId = String(orderId).split("_")[0];

      if (paymentStatus === "finished" || paymentStatus === "confirmed") {
        if (userId) {
          await db.collection("users").doc(userId).set(
            {
              isVip: true,
              vipActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
          console.log(`User ${userId} set to VIP.`);
        }
      } else {
        console.log(`Non-success status received: ${paymentStatus}`);
      }

      res.status(200).send("OK");
    } catch (e) {
      console.error("nowPaymentsWebhook error:", e);
      res.status(500).send("ERROR");
    }
  });

// ========== 4) Telegram webhook (زي ما عندك) ==========
exports.telegramWebhook = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    res.status(200).send("OK");
    try {
      const update = req.body;
      const message = update.message || update.channel_post;

      if (!message || !message.text) {
        console.log("No valid message text found. Exiting.");
        return;
      }

      const messageText = message.text;
      const upperCaseText = messageText.toUpperCase();

      if (upperCaseText.includes("WIN") || upperCaseText.includes("LOSS")) {
        const result = upperCaseText.includes("WIN") ? "win" : "loss";

        const querySnapshot = await db
          .collection("recommendations")
          .where("status", "==", "active")
          .orderBy("timestamp", "desc")
          .limit(1)
          .get();

        if (!querySnapshot.empty) {
          const docId = querySnapshot.docs[0].id;
          await db.collection("recommendations").doc(docId).update({
            result: result,
            status: "completed",
          });
          console.log(`Result updated to ${result}`);
        }
      } else if (messageText.includes("💳")) {
        const lines = messageText.split("\n").filter((line) => line.trim() !== "");
        const recommendationData = {};

        for (const line of lines) {
          if (line.startsWith("💳")) {
            recommendationData.pair = line.replace("💳", "").trim();
          } else if (line.startsWith("🔥")) {
            recommendationData.timeframe = line.replace("🔥", "").trim();
          } else if (line.startsWith("⌛️")) {
            recommendationData.entryTime = line.replace("⌛️", "").trim();
          } else if (line.startsWith("🔽") || line.startsWith("🔼")) {
            recommendationData.direction = line.split(" ")[1]?.toLowerCase();
          } else if (line.includes("Forecast:")) {
            const match = line.match(/([\d.]+)%/);
            if (match) recommendationData.forecast = match[1];
          } else if (line.includes("Payout:")) {
            const match = line.match(/([\d.]+)%/);
            if (match) recommendationData.payout = match[1];
          }
        }

        if (
          recommendationData.pair &&
          recommendationData.timeframe &&
          recommendationData.entryTime &&
          recommendationData.direction
        ) {
          recommendationData.status = "active";
          recommendationData.result = null;
          recommendationData.isVip = true;
          recommendationData.timestamp = admin.firestore.Timestamp.now();

          console.log("Attempting to add document:", JSON.stringify(recommendationData, null, 2));
          await db.collection("recommendations").add(recommendationData);
          console.log("Successfully added new recommendation.");
        } else {
          console.log("Essential data missing after parsing. Ignoring.", recommendationData);
        }
      }
    } catch (error) {
      console.error("CRITICAL ERROR:", error);
    }
  });
