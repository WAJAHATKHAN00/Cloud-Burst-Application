class PredictionService {
  static Map<String, dynamic> predict(Map<String, dynamic> data) {
    final first = data["list"][0];

    double humidity = (first["main"]["humidity"] as num).toDouble(); // %
    double pressure = (first["main"]["pressure"] as num).toDouble(); // hPa
    double wind = (first["wind"]["speed"] as num).toDouble(); // m/s
    double clouds = (first["clouds"]["all"] as num).toDouble(); // %
    double rain = ((first["pop"] ?? 0) as num).toDouble(); // 0–1

    // 🔥 Normalize values (0 → 1 scale)

    double rainScore = rain; // already 0–1

    double cloudScore = clouds / 100;

    double humidityScore = humidity / 100;

    double windScore = (wind / 15).clamp(0, 1);

    double pressureScore =
    ((1015 - pressure) / 20).clamp(0, 1);

    double confidenceRaw =
        (rainScore * 0.50) +
            (cloudScore * 0.20) +
            (humidityScore * 0.10) +
            (windScore * 0.10) +
            (pressureScore * 0.10);

    int confidence = (confidenceRaw * 100).toInt();
    // 🚨 Risk classification
    String risk;
    if (confidence >= 70) {
      risk = "HIGH RISK";
    } else if (confidence >= 40) {
      risk = "MODERATE RISK";
    } else {
      risk = "LOW RISK";
    }

    return {
      "risk": risk,
      "confidence": confidence,
    };
  }
  static String getMessage(Map<String, dynamic> data) {
    final first = data["list"][0];

    double humidity = (first["main"]["humidity"] as num).toDouble();
    double pressure = (first["main"]["pressure"] as num).toDouble();
    double wind = (first["wind"]["speed"] as num).toDouble();
    double clouds = (first["clouds"]["all"] as num).toDouble();
    double rain = ((first["pop"] ?? 0) as num).toDouble() * 100;

    // 🔥 Smart conditions

    if (rain > 60) {
      return "Heavy rain expected. Stay alert ⚠️";
    }

    if (clouds > 70 && humidity > 60) {
      return "Cloud buildup detected. Rain possible";
    }

    if (pressure < 1000) {
      return "Low pressure system. Weather may worsen";
    }

    if (wind > 10) {
      return "Strong winds detected. Be cautious";
    }

    if (rain > 20) {
      return "Light rain possible in coming hours";
    }

    return "Stable conditions. No immediate risk";
  }
}
