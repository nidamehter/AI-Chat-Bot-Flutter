// import 'package:flutter_dotenv/flutter_dotenv.dart';
/*
class ApiService {
    static String apiKey = 'AIzaSyD97GfwZhd8wVoP6NrINE1bWusli8Cakno';
    // static String apiKey = dotenv.env['API_KEY'] ?? 'API_KEY not found';

}
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
    static const String baseUrl = "http://10.0.2.2:8000"; // Eğer emülatörse "http://10.0.2.2:8000" yap

    static Future<String> sendMessage(String message) async {
        final url = Uri.parse('$baseUrl/chat');
        print("API'ye Gönderilen Veri: ${jsonEncode({"message": message})}");

        try {
            final response = await http.post(
                url,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"message": message}), //  JSON verisini doğru formatta gönder
            );

            if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                return data["response"]; //  API'nin verdiği cevabı al
            } else {
                return "Sunucu hatası: ${response.statusCode}";
            }
        } catch (e) {
            return "Bağlantı hatası: $e";
        }
    }
}

