const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.telegramWebhook = functions.https.onRequest(async (req, res) => {
  // استجب لتليجرام فورًا لمنع أي مشاكل
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

    // --- الحالة الأولى: الرسالة هي نتيجة ---
    if (upperCaseText.includes("WIN") || upperCaseText.includes("LOSS")) {
      const result = upperCaseText.includes("WIN") ? "win" : "loss";
      
      const querySnapshot = await db.collection("recommendations")
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
    } 
    // --- الحالة الثانية: الرسالة هي توصية جديدة ---
    else if (messageText.includes("💳")) {
      const lines = messageText.split('\n').filter(line => line.trim() !== '');
      const recommendationData = {};

      // الطريقة الجديدة لتحليل كل سطر على حدة
      for (const line of lines) {
        if (line.startsWith('💳')) {
          recommendationData.pair = line.replace('💳', '').trim();
        } else if (line.startsWith('🔥')) {
          recommendationData.timeframe = line.replace('🔥', '').trim();
        } else if (line.startsWith('⌛️')) {
          recommendationData.entryTime = line.replace('⌛️', '').trim();
        } else if (line.startsWith('🔽') || line.startsWith('🔼')) {
          // استخراج الكلمة التي بعد الإيموجي
          recommendationData.direction = line.split(' ')[1]?.toLowerCase();
        } else if (line.includes('Forecast:')) {
          const match = line.match(/([\d.]+)%/);
          if (match) recommendationData.forecast = match[1];
        } else if (line.includes('Payout:')) {
          const match = line.match(/([\d.]+)%/);
          if (match) recommendationData.payout = match[1];
        }
      }
      
      // التأكد من وجود البيانات الأساسية قبل الحفظ
      if (recommendationData.pair && recommendationData.timeframe && recommendationData.entryTime && recommendationData.direction) {
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