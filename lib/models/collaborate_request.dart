class CollaborateRequest {
  final String id;
  final String projectId;
  final String senderId;
  final String receiverId;
  final String? message;
  final DateTime sentAt;
  final DateTime? confirmedAt;
  final bool isConfirmed;
  final bool isRejected;

  const CollaborateRequest({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.receiverId,
    this.message,
    required this.sentAt,
    this.confirmedAt,
    this.isConfirmed = false,
    this.isRejected = false,
  });

  factory CollaborateRequest.fromJson(Map<String, dynamic> json) {
    return CollaborateRequest(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      isRejected: json['isRejected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'isConfirmed': isConfirmed,
      'isRejected': isRejected,
    };
  }
}
