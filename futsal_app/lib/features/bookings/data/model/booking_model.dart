import 'package:flutter/material.dart';

class BookingModel {
  final int id;
  final String userId;
  final int groundId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int status;
  final int totalAmount;
  final DateTime createdAt;
  final String groundName;

  BookingModel({
    required this.id,
    required this.userId,
    required this.groundId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.groundName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      userId: json['userId'] as String,
      groundId: json['groundId'] as int,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as int,
      totalAmount: json['totalAmount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      groundName: json['groundName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'groundId': groundId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'groundName': groundName,
    };
  }

  // Helper methods
  bool get isUpcoming {
    final now = DateTime.now();
    return bookingDate.isAfter(now) ||
        (bookingDate.year == now.year &&
            bookingDate.month == now.month &&
            bookingDate.day == now.day);
  }

  bool get isPast {
    return !isUpcoming;
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Completed';
      case 2:
        return 'Cancelled';
      case 3:
        return 'Confirmed';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0:
        return const Color(0xFFFFA500); // Orange for pending
      case 1:
        return const Color(0xFF9C27B0); // Purple for completed
      case 2:
        return const Color(0xFFF44336); // Red for cancelled
      case 3:
        return const Color(0xFF4CAF50); // Green for confirmed
      default:
        return const Color(0xFF757575); // Gray for unknown
    }
  }
}
