import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/providers/settings_provider.dart';
import 'package:chatbotapp/widgets/build_display_image.dart';
import 'package:chatbotapp/widgets/settings_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userImage = '';
  String userName = 'Kullanıcı';
  final ImagePicker _picker = ImagePicker();

  // pick an image
  void pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          file = File(pickedImage.path);
        });
      }
    } catch (e) {
      log('error : $e');
    }
  }

  // get user data
  Future<void> getUserData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userBox = await Boxes.getUser();

      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        if (user != null) {
          setState(() {
            userImage = user.image;
            userName = user.name;
          });
        }
      }
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.checkmark),
            onPressed: () {
              // save data
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: BuildDisplayImage(
                  file: file,
                  userImage: userImage,
                  onPressed: () {
                    pickImage();
                  },
                ),
              ),

              const SizedBox(height: 20.0),

              // user name
              Text(
                userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 40.0),

              FutureBuilder(
                future: Boxes.getSettings(),
                builder: (context, AsyncSnapshot<Box<Settings>> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final settingsBox = snapshot.data!;
                  return ValueListenableBuilder(
                    valueListenable: settingsBox.listenable(),
                    builder: (context, box, child) {
                      if (box.isEmpty) {
                        return Column(
                          children: [
                            SettingsTile(
                              icon: CupertinoIcons.mic,
                              title: 'AI sesini etkinleştir',
                              value: false,
                              onChanged: (value) {
                                final settingProvider =
                                context.read<SettingsProvider>();
                                settingProvider.toggleSpeak(value: value);
                              },
                            ),

                            const SizedBox(height: 10.0),

                            SettingsTile(
                              icon: CupertinoIcons.sun_max,
                              title: 'Tema',
                              value: false,
                              onChanged: (value) {
                                final settingProvider =
                                context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value);
                              },
                            ),
                          ],
                        );
                      } else {
                        final settings = box.getAt(0);
                        return Column(
                          children: [
                            SettingsTile(
                              icon: CupertinoIcons.mic,
                              title: 'AI sesini etkinleştir',
                              value: settings!.shouldSpeak,
                              onChanged: (value) {
                                final settingProvider =
                                context.read<SettingsProvider>();
                                settingProvider.toggleSpeak(value: value);
                              },
                            ),
                            const SizedBox(height: 10.0),
                            SettingsTile(
                              icon: settings.isDarkTheme
                                  ? CupertinoIcons.moon_fill
                                  : CupertinoIcons.sun_max_fill,
                              title: 'Tema',
                              value: settings.isDarkTheme,
                              onChanged: (value) {
                                final settingProvider =
                                context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value);
                              },
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}