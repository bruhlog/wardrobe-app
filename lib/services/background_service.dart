import 'dart:convert';
import 'package:http/http.dart' as http;

class BackgroundService {
  static Future<String?> removeBg(String base64) async {
    try {
      final response = await http.post(
        Uri.parse("https://wardrobe-backend-7q4o.onrender.com/remove-bg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageBase64": base64}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["cleanedImageBase64"];
      }
    } catch (_) {}
    return null;
  }
}
