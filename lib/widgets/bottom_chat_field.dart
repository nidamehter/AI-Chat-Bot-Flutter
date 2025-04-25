import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';

class BottomChatField extends StatefulWidget {
  final ChatProvider chatProvider;

  const BottomChatField({super.key, required this.chatProvider});

  @override
  _BottomChatFieldState createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void sendChatMessage() {
    final message = textController.text.trim();
    if (message.isNotEmpty) {
      widget.chatProvider.sendMessage(message: message); //  Düzeltildi!
      textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "Bir mesaj yazın...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendChatMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendChatMessage,
          ),
        ],
      ),
    );
  }
}
