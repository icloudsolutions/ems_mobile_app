class Message {
  final int id;
  final String subject;
  final String body;
  final int senderId;
  final String senderName;
  final String senderType;
  final int recipientId;
  final String recipientName;
  final String recipientType;
  final DateTime createdDate;
  final bool isRead;
  final String? attachmentUrl;
  final int? studentId;

  Message({
    required this.id,
    required this.subject,
    required this.body,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.recipientId,
    required this.recipientName,
    required this.recipientType,
    required this.createdDate,
    required this.isRead,
    this.attachmentUrl,
    this.studentId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      subject: json['subject'] as String? ?? 'No Subject',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      senderId: json['sender_id'] is List
          ? (json['sender_id'] as List)[0] as int
          : json['sender_id'] as int,
      senderName: json['sender_id'] is List
          ? (json['sender_id'] as List)[1] as String
          : json['sender_name'] as String? ?? 'Unknown',
      senderType: json['sender_type'] as String? ?? 'user',
      recipientId: json['recipient_id'] is List
          ? (json['recipient_id'] as List)[0] as int
          : json['recipient_id'] as int,
      recipientName: json['recipient_id'] is List
          ? (json['recipient_id'] as List)[1] as String
          : json['recipient_name'] as String? ?? 'Unknown',
      recipientType: json['recipient_type'] as String? ?? 'user',
      createdDate: json['create_date'] != null
          ? DateTime.parse(json['create_date'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
      studentId: json['student_id'] is List
          ? (json['student_id'] as List)[0] as int
          : json['student_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'body': body,
      'sender_id': senderId,
      'sender_type': senderType,
      'recipient_id': recipientId,
      'recipient_type': recipientType,
      'is_read': isRead,
      if (studentId != null) 'student_id': studentId,
    };
  }
}
