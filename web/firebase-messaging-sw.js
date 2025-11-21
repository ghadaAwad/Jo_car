// firebase-messaging-sw.js

importScripts("https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js");

// بدّل القيم اللي تحت حسب firebase_options.dart إذا بدك، أو خليه زي ما هو
firebase.initializeApp({
  apiKey: "AIzaSyCLgw2HbhMNGmYSlugh0op0Cmp9EBkEw7c",
  authDomain: "jocar97.firebaseapp.com",
  projectId: "jocar97",
  storageBucket: "jocar97.appspot.com",
  messagingSenderId: "635044060830",
  appId: "1:635044060830:web:xxxxxxxxxxxxxx"
});

// تشغيل FCM بالخلفية
const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("Received background message: ", message);
});
