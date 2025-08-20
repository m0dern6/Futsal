class FutsalDetailsModel {
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
  final String? imageId;
  final String imageUrl;
  final String openTime;
  final String closeTime;
  final String createdAt;
  final int bookingCount;
  final String ownerName;
  final double? distanceKm;
  final List<dynamic> bookedTimeSlots;

  FutsalDetailsModel({
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
    this.imageId,
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
    required this.createdAt,
    required this.bookingCount,
    required this.ownerName,
    this.distanceKm,
    required this.bookedTimeSlots,
  });

  factory FutsalDetailsModel.fromJson(Map<String, dynamic> json) {
    return FutsalDetailsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      ownerId: json['ownerId'] as String,
      pricePerHour: (json['pricePerHour'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: (json['ratingCount'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      imageId: json['imageId'] as String?,
      imageUrl: json['imageUrl'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      createdAt: json['createdAt'] as String,
      bookingCount: (json['bookingCount'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      distanceKm: json['distanceKm'] == null
          ? null
          : (json['distanceKm'] as num).toDouble(),
      bookedTimeSlots: json['bookedTimeSlots'] as List<dynamic>,
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
      'createdAt': createdAt,
      'bookingCount': bookingCount,
      'ownerName': ownerName,
      'distanceKm': distanceKm,
      'bookedTimeSlots': bookedTimeSlots,
    };
  }

  @override
  String toString() => toJson().toString();
}
