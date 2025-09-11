const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// تأكد من أنك قمت بتخزين مفاتيحك بأمان باستخدام الأوامر في الـ Terminal
const NOWPAYMENTS_API_KEY = functions.config().nowpayments.apikey;
const IPN_SECRET_KEY = functions.config().nowpayments.ipnkey;

/**
 * الدالة الأولى: إنشاء فاتورة دفع.
 * يتم استدعاؤها من تطبيق Flutter.
 */
exports.createNowPaymentsInvoice = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be logged in.");
  }

  const userId = context.auth.uid;
  const priceAmount = data.price;
  const plan = data.plan;
  
  if (!priceAmount || !plan) {
     throw new functions.https.HttpsError("invalid-argument", "Price and plan are required.");
  }

  try {
    const response = await axios.post(
      "https://api.nowpayments.io/v1/invoice",
      {
        price_amount: priceAmount,
        price_currency: "usd",
        pay_currency: "usdttrc20",
        order_id: `${userId}_${Date.now()}`,
        order_description: `Subscription for ${plan}`,
        ipn_callback_url: `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/nowPaymentsWebhook`,
      },
      { headers: { "x-api-key": NOWPAYMENTS_API_KEY, "Content-Type": "application/json" } }
    );
    return { paymentUrl: response.data.invoice_url };
  } catch (error) {
    console.error("Error creating NOWPayments invoice:", error.response?.data || error.message);
    throw new functions.https.HttpsError("internal", "Could not create payment invoice.");
  }
});

/**
 * الدالة الثانية: استقبال تأكيد الدفع (Webhook).
 * يتم استدعاؤها من سيرفرات NOWPayments.
 */
exports.nowPaymentsWebhook = functions.https.onRequest(async (req, res) => {
  const ipnHeader = req.headers["x-nowpayments-sig"];
  // يجب إضافة منطق التحقق من التوقيع هنا باستخدام IPN_SECRET_KEY

  const paymentStatus = req.body.payment_status;
  const orderId = req.body.order_id;

  if (paymentStatus === "finished" || paymentStatus === "confirmed") {
    const userId = orderId.split("_")[0];
    try {
      await db.collection("users").doc(userId).update({ isVip: true });
      console.log(`User ${userId} successfully upgraded to VIP.`);
    } catch (error) {
      console.error("Error updating user to VIP:", error);
    }
  }
  res.status(200).send("OK");
});