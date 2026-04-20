class TicketModel {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final String? attachmentUrl;
  final String? assignedTo;
  final String status;
  final DateTime? createdAt;

  TicketModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.attachmentUrl,
    this.assignedTo,
    this.status = 'Menunggu',
    this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      assignedTo: json['assigned_to'] as String?,
      status: json['status'] as String? ?? 'Menunggu',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'attachment_url': attachmentUrl,
      'assigned_to': assignedTo,
      'status': status,
    };
  }
}
