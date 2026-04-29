class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String? image;
  final String type;
  final int referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.image,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: _parseHtmlString(json['message']), // Parse HTML entities
      image: json['image'],
      type: json['type'],
      referenceId: json['reference_id'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static String _parseHtmlString(String htmlString) {
    // Handle HTML entities like &#8377; for ₹
    return htmlString
        .replaceAll('&#8377;', '₹')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}