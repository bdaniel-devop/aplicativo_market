import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_agent_service.dart';

/// Botão flutuante do agente de IA, espelha o widget `AIAgent.tsx` do site.
class AiAgentButton extends StatelessWidget {
  const AiAgentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 96,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'ai_agent_fab',
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => const _AiAgentSheet(),
        ),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
    );
  }
}

class _AiAgentSheet extends StatefulWidget {
  const _AiAgentSheet();

  @override
  State<_AiAgentSheet> createState() => _AiAgentSheetState();
}

class _ChatMessage {
  final String role;
  final String content;
  _ChatMessage(this.role, this.content);
}

class _AiAgentSheetState extends State<_AiAgentSheet> {
  final AiAgentService _service = AiAgentService();
  final TextEditingController _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage('assistant', 'Olá! Sou o assistente da AgroSuste. Como posso ajudar hoje?'),
  ];
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text('Assistente AgroSuste', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            if (!_service.isConfigured)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Agente IA por configurar: defina GROQ_API_KEY ao compilar a app.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildBubble(_messages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Escreva a sua mensagem...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending || !_service.isConfigured ? null : _send,
                    icon: _isSending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryGreen : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.content, style: TextStyle(color: isUser ? Colors.white : AppTheme.darkText, fontSize: 13)),
      ),
    );
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage('user', text));
      _isSending = true;
      _inputController.clear();
    });
    try {
      final reply = await _service.sendMessage(_messages.map((m) => {'role': m.role, 'content': m.content}).toList());
      setState(() => _messages.add(_ChatMessage('assistant', reply)));
    } catch (e) {
      setState(() => _messages.add(_ChatMessage('assistant', 'Não consegui responder agora. Tente novamente mais tarde.')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
