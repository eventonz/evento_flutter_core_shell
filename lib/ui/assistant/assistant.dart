// ignore_for_file: invalid_use_of_protected_member

import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'assistant_controller.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssistantController());
    return Scaffold(
        backgroundColor:Theme.of(context).brightness == Brightness.light
                                ? AppColors.darkBlack
                                : AppColors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
           title: const AppText(
            '',
            style: AppStyles.appBarTitle,
          ),
          
          actions: [
            IconButton(
                onPressed: controller.showPromptRemoveMessages,
                icon: const Icon(
                  FeatherIcons.xCircle,
                  size: 18,
                ))
          ],
        ),
        body: Column(
         
          children: [
            GetBuilder<AssistantController>(
              builder: (_) {
                return Expanded(child: Obx(() {
                  final chatMessages = controller.chatMessages.value;
                  return ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      itemCount: chatMessages.length,
                      itemBuilder: (_, i) {
                        final chatMessage = chatMessages[i];
                        return ChatMessage(message: chatMessage);
                      });
                }));
              },
            ),
            Obx(() => LinearProgressIndicator(
                  value: controller.assistantResponseSnapshot.value ==
                          DataSnapShot.loading
                      ? null
                      : 0,
                  minHeight: 0.8,
                  backgroundColor: AppColors.headerText,
                )),
            Container(
              
              child: SafeArea(
                
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                               
                
                        controller: controller.messageTextEditingController,
                        onChanged: (value) =>
                            controller.messageText.value = value,
                        decoration: InputDecoration(
                        hintText: '${AppLocalizations.of(context)!.askAQuestion}...',
                        hintStyle: TextStyle(color:Theme.of(context).brightness == Brightness.light
                                ? AppColors.white
                                : AppColors.darkBlack),
                        border: InputBorder.none
                      ),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      FloatingActionButton.small(
                    onPressed: controller.sendMessage,
                    child: Icon(Icons.send,color: Colors.white,size: 16,),
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                  ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.message});
  final ChatMessageM message;

  String getUserName() {
    return message.role == 'user' ? 'You' : 'Athlete Guide Assistant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
  
      padding: const EdgeInsets.all(16),
      //color: message.role == 'user' ? AppColors.white : AppColors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: message.role == 'user' ? AppColors.primary : AppColors.grey,
                radius: 12,
                child: AppText(
                  getUserName()[0],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.white
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              AppText(
                getUserName(),
              )
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          AppText(
            message.content!,
            fontSize: 16,
          )
        ],
      ),
    );
  }
}
