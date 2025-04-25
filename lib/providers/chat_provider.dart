import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chatbotapp/apis/api_service.dart';
import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _inChatMessages = [];
  final PageController _pageController = PageController();
  List<XFile>? _imagesFileList = [];
  int _currentIndex = 0;
  String _currentChatId = '';
  bool _isLoading = false;

  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

  static Future<void> initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>('chat_history_box');
    }
  }

  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  /// **📝 Güncellenmiş API Çağrısı**
  Future<void> sendMessage({required String message}) async {
    setLoading(value: true);
    String chatId = getChatId();

    final userMessage = Message(
      messageId: const Uuid().v4(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: [],
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    try {
      print("API'ye İstek Atılıyor: $message"); // ✅ Debug için eklendi
      final botReply = await ApiService.sendMessage(message);
      print("API Yanıtı: $botReply"); // ✅ Debug için eklendi

      final assistantMessage = Message(
        messageId: const Uuid().v4(),
        chatId: chatId,
        role: Role.assistant,
        message: StringBuffer(botReply),
        imagesUrls: [],
        timeSent: DateTime.now(),
      );

      _inChatMessages.add(assistantMessage);
    } catch (e) {
      log('API Hatası: $e');
      _inChatMessages.add(Message(
        messageId: const Uuid().v4(),
        chatId: chatId,
        role: Role.assistant,
        message: StringBuffer("Hata: Sunucuya ulaşılamadı."),
        imagesUrls: [],
        timeSent: DateTime.now(),
      ));
    } finally {
      setLoading(value: false);
      notifyListeners();
    }
  }


  String getChatId() {
    return currentChatId.isEmpty ? const Uuid().v4() : currentChatId;
  }

  void addUserMessage(String message) {
    _inChatMessages.add(Message(
      messageId: const Uuid().v4(),
      chatId: _currentChatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: [],
      timeSent: DateTime.now(),
    ));
    notifyListeners();
  }

  void addBotMessage(String message) {
    _inChatMessages.add(Message(
      messageId: const Uuid().v4(),
      chatId: _currentChatId,
      role: Role.assistant,
      message: StringBuffer(message),
      imagesUrls: [],
      timeSent: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> prepareChatRoom({required bool isNewChat, required String chatID}) async {
    if (isNewChat) {
      _inChatMessages.clear();
      _currentChatId = chatID;
    } else {
      _currentChatId = chatID;
    }
    notifyListeners();
  }

  Future<void> deleteChatMessages({required String chatId}) async {
    if (Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    if (_currentChatId == chatId) {
      _currentChatId = '';
      _inChatMessages.clear();
    }

    notifyListeners();
  }
}
