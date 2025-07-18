import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/utils/api_handler.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/preferences.dart';
import '../../core/overlays/toast.dart';
import '../../core/utils/logger.dart';
import 'assistant_controller.dart';

class AssistantV2Controller extends GetxController {
  late String url;
  final messagesSnapshot = DataSnapShot.loading.obs;
  final assistantResponseSnapshot = DataSnapShot.initial.obs;
  final configSnapshot = DataSnapShot.loading.obs;
  late Items item;
  final TextEditingController messageTextEditingController =
      TextEditingController();
  final ScrollController scrollController = ScrollController();
  final messageText = ''.obs;
  final chatMessages = <ChatMessageM>[].obs;
  final dio = Dio();
  final isAssistantActive = false.obs;
  final assistantConfig = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    loadAssistantConfig();
    loadPreviousMessages();
  }

  Future<void> loadAssistantConfig() async {
    try {
      configSnapshot.value = DataSnapShot.loading;

      // Get assistant configuration from the new API endpoint
      final response = await ApiHandler.genericGetHttp(
          url:
              'https://ai.evento.co.nz/api/assistants/${item.assistantId}/config');

      assistantConfig.value = response.data;
      isAssistantActive.value = response.data['status'] == 'active';

      configSnapshot.value = DataSnapShot.loaded;

      // If assistant is not active, show error message
      if (!isAssistantActive.value) {
        ToastUtils.show('Assistant is currently not available');
      }
    } catch (e) {
      Logger.e('Error loading assistant config: $e');
      configSnapshot.value = DataSnapShot.error;
      ToastUtils.show('Failed to load assistant configuration');
    }
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
          content: assistantConfig['welcome_message'] ??
              AppLocalizations.of(Get.context!)!.defaultAssistantMessage);
      chatMessages.add(defaultMessage);
      DatabaseHandler.insertChatMessage(defaultMessage);
    }
  }

  void showPromptRemoveMessages() {
    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => CupertinoAlertDialog(
        title: AppText(
          AppLocalizations.of(Get.context!)!.wouldYouLikeToRemoveAllMessages,
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            child: AppText(
              AppLocalizations.of(Get.context!)!.yes,
              color: AppColors.grey,
            ),
            onPressed: () => removeAllMessages(),
          ),
          CupertinoDialogAction(
            child: AppText(
              AppLocalizations.of(Get.context!)!.cancel,
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

  Future<Map<String, dynamic>> callServer(String message) async {
    try {
      final response = await ApiHandler.postHttp(
          baseUrl: 'https://ai.evento.co.nz/api/assistants/${item.assistantId}/chat',
          endPoint: '',
          body: {'message': message, 'messages': []},
          timeout: 30);
      print('Assistant response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error calling assistant: $e');
      rethrow;
    }
  }

  void sendMessage() async {
    try {
      if (messageText.value.isEmpty) return;

      // Check if assistant is active before sending message
      if (!isAssistantActive.value) {
        ToastUtils.show('Assistant is currently not available');
        return;
      }

      // Store the message before clearing
      final userInput = messageText.value;

      // Add user message to chat
      final userMessage = ChatMessageM(
          role: 'user', content: '${item.prefixprompt} ${userInput}');
      final userMessage2 = ChatMessageM(role: 'user', content: userInput);
      chatMessages.add(userMessage);
      DatabaseHandler.insertChatMessage(userMessage2);

      // Clear input and scroll
      messageTextEditingController.clear();
      messageText.value = '';
      scrollToBottom();

      // Show loading indicator
      assistantResponseSnapshot.value = DataSnapShot.loading;

      // ===== IMAGE DETECTION FEATURE - COMMENT OUT TO DISABLE =====
      // Check if user message contains "image" keyword
      print('DEBUG: User input: "$userInput"');
      print('DEBUG: Contains image: ${userInput.toLowerCase().contains('image')}');
      
      if (userInput.toLowerCase().contains('image')) {
        print('DEBUG: Image detected! Returning random image response');
        // Return a random image response
        final randomImages = [
          'https://picsum.photos/400/300?random=1',
          'https://picsum.photos/400/300?random=2',
          'https://picsum.photos/400/300?random=3',
          'https://picsum.photos/400/300?random=4',
          'https://picsum.photos/400/300?random=5',
        ];
        
        final randomImage = randomImages[DateTime.now().millisecond % randomImages.length];
        print('DEBUG: Selected random image: $randomImage');
        
        final assistantMessage = ChatMessageM(
            role: 'assistant',
            content: 'Here\'s a random image for you!\n\n![Random Image]($randomImage)');
        chatMessages.add(assistantMessage);
        DatabaseHandler.insertChatMessage(assistantMessage);
      } else {
        print('DEBUG: No image keyword found, calling AI API');
        // Call the new assistant API
        final response = await callServer(userInput);

        // Add assistant response to chat
        final assistantMessage = ChatMessageM(
            role: 'assistant',
            content: response['response'] ??
                response['message'] ??
                'No response received');
        chatMessages.add(assistantMessage);
        DatabaseHandler.insertChatMessage(assistantMessage);
      }
      // ===== END IMAGE DETECTION FEATURE =====

      assistantResponseSnapshot.value = DataSnapShot.loaded;
      scrollToBottom();
    } catch (e) {
      print('Error in sendMessage: $e');
      assistantResponseSnapshot.value = DataSnapShot.error;
      ToastUtils.show('Failed to get response from assistant');
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
