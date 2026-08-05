import 'chat_message_model.dart';

class ConversationModel {
  ConversationModel({required this.id, List<ChatMessageModel>? messages})
    : messages = messages ?? [];

  final String id;
  final List<ChatMessageModel> messages;
}
