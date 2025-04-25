import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  // Get the chat history box
  static Future<Box<ChatHistory>> getChatHistory() async {
    if (!Hive.isBoxOpen(Constants.chatHistoryBox)) {
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    return Hive.box<ChatHistory>(Constants.chatHistoryBox);
  }

  // Get user box
  static Future<Box<UserModel>> getUser() async {
    if (!Hive.isBoxOpen(Constants.userBox)) {
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    return Hive.box<UserModel>(Constants.userBox);
  }

  // Get settings box
  static Future<Box<Settings>> getSettings() async {
    if (!Hive.isBoxOpen(Constants.settingsBox)) {
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
    return Hive.box<Settings>(Constants.settingsBox);
  }
}