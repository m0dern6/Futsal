class TrendingGroundModel {
  final int id;
  final String name;
  final String location;
  final String ownerId;
  final int pricePerHour;
  final double averageRating;
  final int ratingCount;
  final double latitude;
  final double longitude;
  final String description;
  final int? imageId; // Made nullable
  final String imageUrl;
  final String openTime;
  final String closeTime;
  final DateTime createdAt;
  final int bookingCount;
  final String ownerName;
  final double? distanceKm; // Made nullable
  final List<BookedTimeSlot> bookedTimeSlots;

  TrendingGroundModel({
    required this.id,
    required this.name,
    required this.location,
    required this.ownerId,
    required this.pricePerHour,
    required this.averageRating,
    required this.ratingCount,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.imageId, // Made nullable
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
    required this.createdAt,
    required this.bookingCount,
    required this.ownerName,
    this.distanceKm, // Made nullable
    required this.bookedTimeSlots,
  });

  factory TrendingGroundModel.fromJson(Map<String, dynamic> json) {
    return TrendingGroundModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      ownerId: json['ownerId'] as String,
      pricePerHour: json['pricePerHour'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      imageId: json['imageId'] as int?, // Handle null
      imageUrl: json['imageUrl'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      bookingCount: json['bookingCount'] as int,
      ownerName: json['ownerName'] as String,
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : null, // Handle null
      bookedTimeSlots: (json['bookedTimeSlots'] as List<dynamic>)
          .map((e) => BookedTimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'ownerId': ownerId,
      'pricePerHour': pricePerHour,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'openTime': openTime,
      'closeTime': closeTime,
      'createdAt': createdAt.toIso8601String(),
      'bookingCount': bookingCount,
      'ownerName': ownerName,
      'distanceKm': distanceKm,
      'bookedTimeSlots': bookedTimeSlots.map((e) => e.toJson()).toList(),
    };
  }
}

class BookedTimeSlot {
  final DateTime bookingDate;
  final String startTime;
  final String endTime;

  BookedTimeSlot({
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });

  factory BookedTimeSlot.fromJson(Map<String, dynamic> json) {
    return BookedTimeSlot(
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
