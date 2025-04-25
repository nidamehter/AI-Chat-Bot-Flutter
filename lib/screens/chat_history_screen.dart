import 'package:flutter/material.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/widgets/chat_history_widget.dart';
import 'package:chatbotapp/widgets/empty_history_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text('Chat Geçmişi'),
      ),
      body: FutureBuilder(
        future: Boxes.getChatHistory(), // ✅ Future bekleniyor
        builder: (context, AsyncSnapshot<Box<ChatHistory>> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // ✅ Yüklenme ekranı ekleyelim
          }

          final chatHistoryBox = snapshot.data!;

          return ValueListenableBuilder(
            valueListenable: chatHistoryBox.listenable(), // ✅ Artık çalışacak
            builder: (context, box, widget) {
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final chat = box.getAt(index) as ChatHistory;
                  return ListTile(
                    title: Text(chat.prompt),
                    subtitle: Text(chat.response),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
