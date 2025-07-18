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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

import 'assistantv2_controller.dart';
import 'assistant_controller.dart';

class AssistantV2Screen extends StatelessWidget {
  const AssistantV2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssistantV2Controller());
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
            GetBuilder<AssistantV2Controller>(
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
                            hintText:
                                '${AppLocalizations.of(context)!.askAQuestion}...',
                            hintStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.white
                                    : AppColors.darkBlack),
                            border: InputBorder.none),
                      )),
                      SizedBox(
                        width: 2.w,
                      ),
                      FloatingActionButton.small(
                        onPressed: controller.sendMessage,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16,
                        ),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssistantV2Controller>();
    final isUser = message.role == 'user';
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isUser) ...[
            // User message - speech bubble on the right
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isLightMode ? Colors.grey[600] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content!
                    .replaceAll('${controller.item.prefixprompt}', ''),
                style: TextStyle(
                  fontSize: 16,
                  color: isLightMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ] else ...[
            // Assistant message - plain text on the left with avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assistant avatar
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.grey,
                    backgroundImage:
                        controller.assistantConfig['avatar'] != null
                            ? NetworkImage(controller.assistantConfig['avatar'])
                            : null,
                    child: controller.assistantConfig['avatar'] == null
                        ? AppText(
                            'A',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ),
                // Assistant message content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MarkdownBody(
                              data: message.content!.replaceAll(
                                  '${controller.item.prefixprompt}', ''),
                              onTapLink: (text, url, title) async {
                                if (url != null) {
                                  final Uri uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ToastUtils.show('Could not open link');
                                  }
                                }
                              },
                              builders: {
                                'img': CustomImageBuilder(),
                              },
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                strong: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                em: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                h1: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                h2: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                h3: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                listBullet: TextStyle(
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                                a: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          // Report flag button
                          GestureDetector(
                            onTap: () {
                              void showFlagMessageDialog(BuildContext context,
                                  void Function(String reason) onSubmit) {
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
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 24),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Flag this message',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 16),
                                                ...options.map((option) {
                                                  final isSelected =
                                                      selectedReason == option;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedReason = option;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 16),
                                                      margin: EdgeInsets.only(
                                                          bottom: 8),
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? AppColors.primary
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? AppColors
                                                                  .primary
                                                              : Colors
                                                                  .grey[300]!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Radio<String>(
                                                            value: option,
                                                            groupValue:
                                                                selectedReason,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                selectedReason =
                                                                    value;
                                                              });
                                                            },
                                                            activeColor:
                                                                AppColors
                                                                    .primary,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(option),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text('Cancel'),
                                                    ),
                                                    SizedBox(width: 8),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            AppColors.primary,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                      ),
                                                      onPressed:
                                                          selectedReason == null
                                                              ? null
                                                              : () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  onSubmit(
                                                                      selectedReason!);
                                                                },
                                                      child: Text(
                                                        'Submit',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
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
                                  'content': message.content!.replaceAll(
                                      '${controller.item.prefixprompt}', ''),
                                }, endPoint: 'assistant/report');
                                ToastUtils.show(
                                    'Report submitted successfully!');
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.flag_outlined,
                                  size: 16, color: Color(0xFF757575)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class CustomImageBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String? src = element.attributes['src'];
    final String? alt = element.attributes['alt'];

    if (src == null || src.isEmpty) {
      return null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          src,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    alt ?? 'Image failed to load',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
