<p align="center">
  <img src="assets/icon/app_icon.png" width="100" alt="CloudBurst Alert App Icon" />
</p>

# ⚡ CloudBurst Alert

<p align="center">
  <strong>Stay safe with real-time cloudburst risk tracking, live weather updates, and community hazard alerts.</strong>
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white">
  <img alt="OpenWeather" src="https://img.shields.io/badge/OpenWeather-EB6E4B?style=for-the-badge">
  <img alt="OpenStreetMap" src="https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white">
  <img alt="Android" src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white">
</p>

---

## 📱 About CloudBurst Alert

Sudden heavy rain and cloudbursts can cause flash floods and landslides with very little warning. **CloudBurst Alert** is a mobile app designed to keep people informed about cloudburst and extreme weather risks in their area.

By combining live weather forecasts, key environmental indicators (like humidity, cloud cover, and pressure drops), and real-time reports submitted by citizens, the app gives everyone an early heads-up when dangerous weather is brewing.

---

## 📸 App Preview

<p align="center">
  <img src="screenshots/1.png" width="220" alt="Live Weather Dashboard" />
  &nbsp;&nbsp;
  <img src="screenshots/2.PNG" width="220" alt="Interactive Risk Map" />
  &nbsp;&nbsp;
  <img src="screenshots/3.PNG" width="220" alt="Incident Reporting" />
</p>

---

## 🚀 What The App Does

- 🌤️ **Live Risk Dashboard**: Displays current temperature, rain chance, humidity, wind, pressure, and an overall cloudburst risk rating (**Low**, **Moderate**, or **High**).
- 🗺️ **Interactive Risk Map**: Tap any location on OpenStreetMap to analyze weather risk zones with interactive visual circles.
- 📢 **Citizen Hazard Reports**: Spot a landslide or sudden heavy rain? Submit a quick report with your location, intensity, notes, and a camera photo.
- 🔔 **Real-Time Warning Alerts**: Approved user reports stream live across the app so everyone nearby gets notified of active incidents.
- 🔍 **City & Location Search**: Instantly check conditions for cities like Islamabad, Rawalpindi, Murree, Gilgit, Skardu, Lahore, Karachi, or use auto GPS location.
- 🔒 **Privacy Friendly**: No account registration or signup required—uses an anonymous device token to let you track your submitted reports.

---

## 🛠️ Technology & Tools

All technologies powering CloudBurst Alert:

<p align="left">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white">
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white">
  <img alt="OpenWeather" src="https://img.shields.io/badge/OpenWeather_API-EB6E4B?style=for-the-badge">
  <img alt="OpenStreetMap" src="https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white">
  <img alt="Android" src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white">
</p>

---

## 📊 How Cloudburst Risk is Calculated

The app looks at 5 key weather factors from live forecast feeds:

- 🌧️ **Rain Probability** (50% impact)
- ☁️ **Cloud Density** (20% impact)
- 💧 **Humidity Levels** (10% impact)
- 💨 **Wind Speed** (10% impact)
- 📉 **Pressure Drops** (10% impact)

The total score determines the risk category:
- 🟢 **Low Risk**: Normal weather conditions.
- 🟡 **Moderate Risk**: Be cautious, rain or cloud buildup expected.
- 🔴 **High Risk**: High likelihood of intense rainfall / cloudburst.

---

## ⚡ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- VS Code or Android Studio
- Connected Android device or Emulator

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/cloud_burst.git
   cd cloud_burst
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

---

## 📌 Disclaimer

CloudBurst Alert is an advisory and community safety tool. For official emergency warnings and evacuation orders, always follow instructions from local disaster management authorities.

---

<p align="center">
  Made for community safety and disaster awareness.
</p>
