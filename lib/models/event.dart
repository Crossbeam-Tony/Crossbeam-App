enum EventStatus { upcoming, ongoing, completed, cancelled }

class Event {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String organizerId;
  final String organizerAvatar;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime date;
  final String? imageUrl;
  final List<String> confirmedAttendeeIds;
  final List<String> interestedAttendeeIds;
  final EventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.organizerId,
    required this.organizerAvatar,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.date,
    this.imageUrl,
    required this.confirmedAttendeeIds,
    required this.interestedAttendeeIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      organizer: json['organizer'] as String,
      organizerId: json['organizerId'] as String,
      organizerAvatar: json['organizerAvatar'] as String,
      location: json['location'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      date: DateTime.parse(json['date'] as String),
      imageUrl: json['imageUrl'] as String?,
      confirmedAttendeeIds:
          List<String>.from(json['confirmedAttendeeIds'] ?? []),
      interestedAttendeeIds:
          List<String>.from(json['interestedAttendeeIds'] ?? []),
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == 'EventStatus.${json['status']}',
        orElse: () => EventStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'organizerId': organizerId,
      'organizerAvatar': organizerAvatar,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'confirmedAttendeeIds': confirmedAttendeeIds,
      'interestedAttendeeIds': interestedAttendeeIds,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
