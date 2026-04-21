const functions = require("firebase-functions");
const admin = require("firebase-admin");
//const fetch = require("node-fetch");

admin.initializeApp();

exports.runCloudburstPrediction = functions.pubsub
  .schedule("every 10 minutes")
  .onRun(async (context) => {

    const db = admin.firestore();

    const devicesSnapshot = await db.collection("devices").get();

    for (const doc of devicesSnapshot.docs) {

      const device = doc.data();
      const lat = device.latitude;
      const lon = device.longitude;

      const apiKey = "e0c42476cbfb47c60a47e024140742b3";

      const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&appid=${apiKey}&units=metric`;

      const res = await fetch(url);
      const data = await res.json();

      // =============================
      // 📊 EXTRACT DATA
      // =============================

      const humidity = data.current.humidity;
      const pressure = data.current.pressure;
      const clouds = data.current.clouds;
      const wind = data.current.wind_speed;
      const pop = data.hourly[0].pop;

      // 👉 Minutely rain (last 10 minutes)
      const minutely = data.minutely.slice(0, 10);

      let rainSum = 0;
      minutely.forEach(m => {
        rainSum += m.precipitation;
      });

      // 👉 Convert to mm/hr
      const rainIntensity = rainSum * 6;

      // =============================
      // 🧠 CLOUD BURST LOGIC
      // =============================

      let riskLevel = "LOW";
      let probability = 0;

      if (
        rainIntensity > 50 &&
        clouds > 80 &&
        humidity > 70 &&
        pop > 0.7
      ) {
        riskLevel = "HIGH";
        probability = 80 + Math.random() * 20;
      }
      else if (
        rainIntensity > 20 &&
        clouds > 60
      ) {
        riskLevel = "MEDIUM";
        probability = 40 + Math.random() * 20;
      }
      else {
        riskLevel = "LOW";
        probability = 10 + Math.random() * 20;
      }

      // =============================
      // 💾 SAVE TO FIRESTORE
      // =============================

      await db.collection("predictions").add({
        latitude: lat,
        longitude: lon,
        rainIntensity,
        humidity,
        pressure,
        clouds,
        windSpeed: wind,
        pop,
        cloudburstProbability: Math.round(probability),
        riskLevel,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Saved:", riskLevel, probability);
    }

    return null;
  });