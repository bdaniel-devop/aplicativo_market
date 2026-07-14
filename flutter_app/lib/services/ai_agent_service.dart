import 'package:dio/dio.dart';

/// Chama a Groq directamente do telemóvel, tal como o `AIAgent.tsx` do site
/// chama a partir do browser. A chave nunca é commitada: é injectada em
/// build/run com `--dart-define=GROQ_API_KEY=...`.
class AiAgentService {
  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _model = 'llama-3.3-70b-versatile';
  static const _systemPromptPt =
      'És o assistente virtual da AgroSuste Market, uma plataforma moçambicana que liga produtores agrícolas a compradores. '
      'Responde em português, de forma curta, simpática e útil sobre como usar a plataforma, produtos agrícolas e o processo de compra/venda.';

  final Dio _dio = Dio();

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> sendMessage(List<Map<String, String>> history) async {
    if (!isConfigured) {
      throw Exception('Agente IA não configurado (defina GROQ_API_KEY).');
    }

    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'}),
      data: {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemPromptPt},
          ...history,
        ],
      },
    );

    return response.data['choices'][0]['message']['content'] as String;
  }
}
