import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'database_service.dart';

class AIService {
  AIService._privateConstructor();
  static final AIService instance = AIService._privateConstructor();

  static const String _defaultQuote = 
      "Consistency is not about perfection; it is about progress. Tiny habits build extraordinary results.";

  Future<String?> getApiKey() async {
    return await DatabaseService.instance.fetchSessionValue('gemini_api_key');
  }

  Future<void> saveApiKey(String apiKey) async {
    await DatabaseService.instance.saveSessionValue('gemini_api_key', apiKey.trim());
  }

  Future<String> getTodayMotivation(String userName) async {
    final db = DatabaseService.instance;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // e.g. "2026-05-24"

    // Check cached date
    final cachedDate = await db.fetchSessionValue('motivation_date');
    final cachedQuote = await db.fetchSessionValue('motivation_quote');

    if (cachedDate == todayStr && cachedQuote != null && cachedQuote.isNotEmpty) {
      return cachedQuote;
    }

    // Otherwise, fetch from Gemini API
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      // Return default quote if no API key is configured
      return _defaultQuote;
    }

    try {
      final client = HttpClient();
      // Setup timeout to ensure app does not block
      client.connectionTimeout = const Duration(seconds: 8);
      
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
      );
      
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      
      final prompt = "Berikan 1 kalimat kutipan motivasi yang sangat kuat, inspiratif, dan singkat (maksimal 15 kata) untuk seseorang bernama $userName yang sedang berjuang membangun kebiasaan baik dan menyelesaikan tugas hariannya. Tulis kutipan tersebut dalam Bahasa Indonesia. Langsung berikan kutipannya saja tanpa tanda kutip ganda pembuka/penutup, dan tanpa basa-basi kata pengantar.";
      
      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": prompt
              }
            ]
          }
        ]
      });

      request.write(requestBody);
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);
        
        final String text = json['candidates'][0]['content']['parts'][0]['text'] ?? '';
        final cleanText = text.trim().replaceAll('"', '');
        
        if (cleanText.isNotEmpty) {
          // Cache the fresh quote
          await db.saveSessionValue('motivation_date', todayStr);
          await db.saveSessionValue('motivation_quote', cleanText);
          client.close();
          return cleanText;
        }
      }
      client.close();
    } catch (e) {
      // Fallback on network or API failure
      if (cachedQuote != null && cachedQuote.isNotEmpty) {
        return cachedQuote; // Use stale cache on error
      }
    }

    return _defaultQuote;
  }
}
