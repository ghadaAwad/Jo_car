// functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Stripe
const stripe = require("stripe")(functions.config().stripe.secret);

//
// 🔹 Stripe Checkout Session (FINAL FIXED VERSION)
//
exports.createCheckoutSession = functions.https.onCall(async (data, context) => {
  const { amount, bookingId, carName } = data;

  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in."
    );
  }

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      customer_email: context.auth.token.email || undefined,

      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: carName || "Car Booking",
            },
            unit_amount: amount, // ❗ بدون أي ضرب ×100
          },
          quantity: 1,
        },
      ],

      success_url: `https://jocar97.web.app/payment_success?bookingId=${bookingId}`,
      cancel_url: "https://jocar97.web.app/payment_failed",
    });

    return { url: session.url };
  } catch (err) {
    console.error("Stripe error:", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

//
// 🔹 إشعار للبروفايدر عند الإنشاء
//
exports.notifyProviderOnBooking = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const providerId = data.providerId;
    const userName = data.userName;
    const carMake = data.carMake;
    const carModel = data.carModel;

    const providerDoc = await admin
      .firestore()
      .collection("users")
      .doc(providerId)
      .get();

    if (!providerDoc.exists) {
      console.log("❌ Provider not found");
      return null;
    }

    const providerData = providerDoc.data();
    const fcmToken = providerData.fcmToken;

    if (!fcmToken) {
      console.log("❌ Provider has no FCM token");
      return null;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: "New Booking Request",
        body: `${userName} booked your ${carMake} ${carModel}`,
      },
      data: {
        type: "booking",
        bookingId: context.params.bookingId,
      },
    };

    await admin.messaging().send(message);

    console.log("📨 Notification sent to provider successfully!");

    return true;
  });
// ------------------------------
// 🔄 Auto Update Booking Status
// ------------------------------
exports.updateBookingsStatus = functions.pubsub
  .schedule("every 30 minutes")
  .timeZone("Asia/Amman")
  .onRun(async (context) => {
    const now = new Date();

    const snap = await admin.firestore().collection("bookings").get();
    const batch = admin.firestore().batch();

    snap.forEach((doc) => {
      const data = doc.data();

      const startStr = data.startDate; // stored as ISO string
      const days = data.days || 1;
      const status = data.status || "pending";

      if (!startStr) return;

      const start = new Date(startStr);
      const end = new Date(start);
      end.setDate(end.getDate() + days);

      let newStatus = status;

      if (status !== "canceled") {
        if (now > end) {
          newStatus = "completed";
        } else if (now >= start && now <= end) {
          newStatus = "active";
        } else {
          // قبل الحجز
          // pending و confirmed بنخليهم زي ما هم
        }
      }

      if (newStatus !== status) {
        batch.update(doc.ref, { status: newStatus });
      }
    });

    await batch.commit();
    console.log("✅ Bookings auto-updated successfully!");
    return null;
  });
