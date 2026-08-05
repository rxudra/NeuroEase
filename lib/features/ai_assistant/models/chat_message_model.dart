class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    this.time,
  });

  final String id;
  String text;
  String sender; // 'user' or 'ai'
  DateTime? time;
}
