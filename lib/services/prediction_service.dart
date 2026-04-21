class PredictionService {
  static String predict(Map<String, dynamic> data) {
    final list = data["list"];

    if (list.length < 3) return "LOW RISK";

    final now = list[0];
    final next = list[1];
    final later = list[2];

    double humidityNow = (now["main"]["humidity"] as num).toDouble();
    double humidityNext = (next["main"]["humidity"] as num).toDouble();

    double pressureNow = (now["main"]["pressure"] as num).toDouble();
    double pressureNext = (next["main"]["pressure"] as num).toDouble();

    double rainNow = ((now["pop"] ?? 0) as num).toDouble() * 100;
    double rainNext = ((next["pop"] ?? 0) as num).toDouble() * 100;
    double rainLater = ((later["pop"] ?? 0) as num).toDouble() * 100;

    double cloudsNow = (now["clouds"]["all"] as num).toDouble();
    double cloudsNext = (next["clouds"]["all"] as num).toDouble();

    int score = 0;

    // 🌧 Rain increasing rapidly
    if (rainNext > rainNow && rainLater > rainNext) score += 3;

    // 📉 Pressure dropping
    if (pressureNext < pressureNow) score += 2;

    // 💧 Humidity rising
    if (humidityNext > humidityNow) score += 2;

    // ☁️ Clouds increasing
    if (cloudsNext > cloudsNow) score += 2;

    // Extreme condition
    if (rainLater > 70 && humidityNext > 80) score += 3;

    if (score >= 7) return "HIGH RISK";
    if (score >= 4) return "MODERATE RISK";
    return "LOW RISK";
  }
}