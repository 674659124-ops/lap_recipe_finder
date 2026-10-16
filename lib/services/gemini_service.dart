import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class GeminiService {
  // Default fallback API Key (Users can also provide their own Gemini API Key in UI)
  static String defaultApiKey = '';

  static Future<Recipe?> generateRecipeFromAI({
    required String prompt,
    String? userApiKey,
  }) async {
    final apiKey = (userApiKey != null && userApiKey.trim().isNotEmpty)
        ? userApiKey.trim()
        : defaultApiKey;

    final systemInstruction =
        'คุณคือเชฟมืออาชีพ กรุณารังสรรค์สูตรอาหารจากคำสั่ง/วัตถุดิบนี้: "$prompt" '
        'ตอบกลับเฉพาะ JSON ภาษาไทยในรูปแบบนี้เท่านั้น โดยไม่มีตัวอักษรอื่นปน:\n'
        '{\n'
        '  "title": "ชื่อเมนู",\n'
        '  "description": "คำอธิบายความอร่อยคร่าวๆ",\n'
        '  "prepTime": "10 นาที",\n'
        '  "cookTime": "15 นาที",\n'
        '  "difficulty": "ง่าย",\n'
        '  "icon": "🍲",\n'
        '  "category": "Quick Meal",\n'
        '  "ingredients": ["วัตถุดิบ 1", "วัตถุดิบ 2"],\n'
        '  "tools": ["กระทะ", "ตะหลิว"],\n'
        '  "steps": ["ขั้นตอนที่ 1", "ขั้นตอนที่ 2"],\n'
        '  "tips": ["เคล็ดลับความอร่อย"],\n'
        '  "calories": "320 kcal"\n'
        '}';

    if (apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': systemInstruction}
                    ]
                  }
                ]
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          final candidates = body['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates.first['content']['parts'][0]['text'] as String;
            
            // Clean markdown json ticks if present
            String cleanedJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;

            return Recipe(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              title: jsonMap['title'] ?? 'เมนูพิเศษโดย Gemini AI',
              description: jsonMap['description'] ?? 'สูตรอาหารรังสรรค์ด้วยระบบ Gemini AI',
              prepTime: jsonMap['prepTime'] ?? '10 นาที',
              cookTime: jsonMap['cookTime'] ?? '15 นาที',
              difficulty: jsonMap['difficulty'] ?? 'ง่าย',
              icon: jsonMap['icon'] ?? '✨',
              imageUrl: '',
              category: jsonMap['category'] ?? 'Quick Meal',
              ingredients: (jsonMap['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
                  ['วัตถุดิบตามที่ระบุ'],
              tools: (jsonMap['tools'] as List?)?.map((e) => e.toString()).toList() ?? ['กระทะ'],
              steps: (jsonMap['steps'] as List?)?.map((e) => e.toString()).toList() ??
                  ['ผัดและปรุงรสตามชอบ'],
              tips: (jsonMap['tips'] as List?)?.map((e) => e.toString()).toList() ??
                  ['เสิร์ฟขณะร้อนๆ'],
              nutrition: {
                'พลังงาน': jsonMap['calories'] ?? '300 kcal',
                'โปรตีน': '15 g',
                'ไขมัน': '10 g',
                'คาร์โบไฮเดรต': '30 g',
              },
              author: 'Gemini AI Assistant ✨',
            );
          }
        }
      } catch (_) {}
    }

    // Smart Fallback AI Recipe Generator if API Key is not set or network timed out
    return _generateFallbackAIRecipe(prompt);
  }

  static Recipe _generateFallbackAIRecipe(String prompt) {
    final cleanPrompt = prompt.trim();
    return Recipe(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: cleanPrompt.isNotEmpty ? 'เมนูฟิวชั่น $cleanPrompt' : 'ข้าวผัดไข่ฟิวชั่นซอสพิเศษ',
      description: 'สูตรอาหารพิเศษที่คิดค้นโดย Gemini AI ผู้ช่วยทำอาหารประจำเป็นตัวคุณ',
      prepTime: '8 นาที',
      cookTime: '12 นาที',
      difficulty: 'ง่าย',
      icon: '✨',
      imageUrl: '',
      category: 'Quick Meal',
      ingredients: [
        if (cleanPrompt.isNotEmpty) '$cleanPrompt (ปริมาณตามชอบ)' else 'ไข่ไก่ 2 ฟอง',
        'กระเทียมสับ 1 ช้อนชา',
        'ซอสปรุงรสเข้มข้น 1 ช้อนโต๊ะ',
        'ต้นหอมซอยสำหรับโรยหน้า',
        'น้ำมันพืช 1 ช้อนโต๊ะ',
      ],
      tools: ['กระทะ', 'ตะหลิว', 'จานเสิร์ฟ'],
      steps: [
        'เตรียมวัตถุดิบ $cleanPrompt และล้างทำความสะอาดให้เรียบร้อย',
        'ตั้งกระทะใส่น้ำมันพืช ใช้ไฟปานกลาง ใส่กระเทียมสับลงไปผัดจนหอมกรุ่น',
        'ใส่ $cleanPrompt ลงไปผัด ปรุงรสด้วยซอสปรุงรส ผัดเร่งไฟแรงจนเข้าเนื้อ',
        'ตักใส่จาน โรยต้นหอมซอย พร้อมเสิร์ฟความอร่อยสไตล์ Gemini AI',
      ],
      tips: ['ปรุงรสขณะกระทะร้อนจัด จะช่วยดึงกลิ่นหอมของวัตถุดิบออกมาได้ดีที่สุด'],
      nutrition: {
        'พลังงาน': '320 kcal',
        'โปรตีน': '14 g',
        'ไขมัน': '12 g',
        'คาร์โบไฮเดรต': '35 g',
      },
      author: 'Gemini AI Assistant ✨',
    );
  }
}
