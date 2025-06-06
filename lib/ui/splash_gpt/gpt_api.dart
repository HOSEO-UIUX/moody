import 'package:http/http.dart' as http;
import 'dart:convert';

/// GPT API를 사용하여 텍스트의 감정을 분석하는 클래스
///
/// OpenAI의 GPT-3.5 모델을 사용하여 텍스트에서 감정을 추출하고 분석
class GptApi {
  /// OpenAI API 키
  static const String _apiKey =
      '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';

  /// OpenAI API 엔드포인트 URL
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// 주어진 텍스트에서 감정을 분석하여 3가지 주요 감정을 반환
  ///
  /// [text] 분석할 텍스트
  ///
  /// Returns:
  /// - 성공 시: 3가지 감정을 담은 문자열 리스트
  /// - 실패 시: Exception 발생
  static Future<List<String>> analyzeEmotions(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '다음 텍스트에서 가장 강하게 드러나는 3가지 감정을 찾아서 순수 JSON 배열 형태로만 반환해주세요. 마크다운이나 다른 형식 없이 ["감정1", "감정2", "감정3"] 형태로만 반환해주세요. 감정은 한 단어로 표현해주세요.'
            },
            {'role': 'user', 'content': text}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return List<String>.from(jsonDecode(content));
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('😂감정 분석 실패: $e');
      throw Exception('감정 분석 실패: $e');
    }
  }
}
