import 'package:equatable/equatable.dart';

class FutsalGroundModel extends Equatable {
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
  final String imageUrl;
  final String openTime;
  final String closeTime;
  final String createdAt;
  final String ownerName;

  const FutsalGroundModel({
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
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
    required this.createdAt,
    required this.ownerName,
  });

  factory FutsalGroundModel.fromJson(Map<String, dynamic> json) {
    return FutsalGroundModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      ownerId: json['ownerId'],
      pricePerHour: json['pricePerHour'],
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['imageUrl'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      createdAt: json['createdAt'],
      ownerName: json['ownerName'],
    );
  }

  @override
  List<Object?> get props => [id, name, location, pricePerHour, imageUrl];
}
