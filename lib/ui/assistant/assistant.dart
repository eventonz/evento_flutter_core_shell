// ignore_for_file: invalid_use_of_protected_member

import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
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

    final controller = Get.find<AssistantController>();

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
              Expanded(
                child: AppText(
                  getUserName(),
                ),
              ),
              if(message.role != 'user')
              GestureDetector(
                  onTap: () {
                    void showFlagMessageDialog(BuildContext context, void Function(String reason) onSubmit) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          String? selectedReason;
                          final options = [
                            'Incorrect',
                            'Harmful or unsafe',
                            'Biased or offensive',
                          ];

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Flag this message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16),
                                      ...options.map((option) {
                                        final isSelected = selectedReason == option;
                                        return GestureDetector(
                                          onTap: () => setState(() => selectedReason = option),
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                                ),
                                                SizedBox(width: 10),
                                                Text(option, style: TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text('Cancel'),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: selectedReason == null
                                                ? null
                                                : () {
                                              Navigator.of(context).pop();
                                              onSubmit(selectedReason!);
                                            },
                                            child: Text('Submit', style: TextStyle(
                                              color: Colors.white,
                                            ),),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    showFlagMessageDialog(context, (flag) {
                      ApiHandler.postHttp(body: {
                        'race_id': AppGlobals.selEventId,
                        'content': message.content!.replaceAll('${controller.item.prefixprompt}', ''),
                      }, endPoint: 'assistant/report');
                      ToastUtils.show('Report submitted successfully!');
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.flag_outlined, size: 20),
                  )),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          AppText(
            message.content!.replaceAll('${controller.item.prefixprompt}', ''),
            fontSize: 16,
          )
        ],
      ),
    );
  }
}
