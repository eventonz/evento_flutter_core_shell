import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/utils/api_handler.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/preferences.dart';

class AssistantController extends GetxController {
  late String url;
  final messagesSnapshot = DataSnapShot.loading.obs;
  final assistantResponseSnapshot = DataSnapShot.initial.obs;
  late Items item;
  final TextEditingController messageTextEditingController =
      TextEditingController();
  final ScrollController scrollController = ScrollController();
  final messageText = ''.obs;
  final chatMessages = <ChatMessageM>[].obs;
  final dio = Dio();

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    loadPreviousMessages();
  }

  void loadPreviousMessages() async {
    chatMessages.clear();
    chatMessages.addAll(await DatabaseHandler.getAllChatMessages());
    addDefaultMessage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  void addDefaultMessage() {
    if (chatMessages.isEmpty) {
      final defaultMessage = ChatMessageM(
          role: 'assistant',
          content:
              'Ask me any questions about the Athlete Guide - I\'ll try my best to answer.');
      chatMessages.add(defaultMessage);
      DatabaseHandler.insertChatMessage(defaultMessage);
    }
  }

  void showPromptRemoveMessages() {
    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => CupertinoAlertDialog(
        title: const AppText(
          'Would you like to remove all the messages?',
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            child: const AppText(
              'Yes',
              color: AppColors.grey,
            ),
            onPressed: () => removeAllMessages(),
          ),
          CupertinoDialogAction(
            child: AppText(
              'Cancel',
              color: AppColors.primary,
            ),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  void removeAllMessages() {
    Get.back();
    DatabaseHandler.removeAllChatMessages();
    chatMessages.clear();
    addDefaultMessage();
  }

  Future<void> callServer(String message) async {
    String url = 'assistant';

    final res = await ApiHandler.postHttp(
        endPoint: url, body: {
        'request' : message,
        'race_id' : Preferences.getInt(AppKeys.eventId, 0),
        'player_id' : AppGlobals.oneSignalUserId,
    });
    print(res.data);
  }

  void sendMessage() async {

    try {
      if (messageText.value.isEmpty) return;
      callServer(messageText.value);
      final userMessage = ChatMessageM(
          role: 'user', content: messageText.value);
      chatMessages.add(userMessage);
      DatabaseHandler.insertChatMessage(userMessage);
      messageTextEditingController.clear();
      messageText.value = '';
      scrollToBottom();

      final headers = {
        'content-Type': 'application/json',
        'x-api-key': 'sec_qDPiWawARnBc2qT1iVDDOVHaiumJ0Tdr'
      };

      

      

      final data = {
        'stream': true,
        'sourceId': item.sourceId,
        'messages': parsedMessages(chatMessages),
      };
      assistantResponseSnapshot.value = DataSnapShot.loading;
      final response = await dio.post(
        'https://api.chatpdf.com/v1/chats/message',
        data: data,
        options: Options(headers: headers, responseType: ResponseType.stream),
      );
      if (response.statusCode == 200) {
        final Stream stream = response.data.stream;
        String message = '';
        final assistantMessage =
        ChatMessageM(role: 'assistant', content: message);
        chatMessages.add(assistantMessage);
        stream.listen((chunk) {
          final decodedChunk = utf8.decode(chunk);
          message = message + decodedChunk;
          chatMessages.last.content = message;
          update();
          scrollToBottom();
        }, onDone: () {
          debugPrint('Stream completed.');
          DatabaseHandler.insertChatMessage(assistantMessage);
          assistantResponseSnapshot.value = DataSnapShot.loaded;
        });
      } else {
        assistantResponseSnapshot.value = DataSnapShot.error;
      }
    } catch (e) {
      print(((e as DioException).response?.data as ResponseBody));

    }
  }

  List<Map<String, dynamic>> parsedMessages(List<ChatMessageM> messagesM) {
    final messages = List<ChatMessageM>.from(messagesM);
    if (messages.first.role == 'assistant') {
      messages.removeAt(0);
    }
    if (messages.length <= 5) {
      return messages.map((message) => message.toJson()).toList();
    } else {
      return messages
          .sublist(messages.length - 5)
          .map((message) => message.toJson())
          .toList();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastEaseInToSlowEaseOut);
    });
  } 
}

class ChatMessageM {
  String? role;
  String? content;

  ChatMessageM({this.role, this.content});

  ChatMessageM.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['content'] = content;
    return data;
  }
}
