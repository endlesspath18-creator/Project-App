import 'user_model.dart';
import 'service_model.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending: return 'PENDING';
      case BookingStatus.accepted: return 'ACCEPTED';
      case BookingStatus.rejected: return 'REJECTED';
      case BookingStatus.inProgress: return 'IN_PROGRESS';
      case BookingStatus.completed: return 'COMPLETED';
      case BookingStatus.cancelled: return 'CANCELLED';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return BookingStatus.pending;
      case 'ACCEPTED': return BookingStatus.accepted;
      case 'REJECTED': return BookingStatus.rejected;
      case 'IN_PROGRESS': return BookingStatus.inProgress;
      case 'COMPLETED': return BookingStatus.completed;
      case 'CANCELLED': return BookingStatus.cancelled;
      default: return BookingStatus.pending;
    }
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final BookingStatus status;
  final DateTime scheduledDate;
  final String address;
  final String? notes;
  final double totalAmount;
  final UserModel? user;
  final ServiceModel? service;

  BookingModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.scheduledDate,
    required this.address,
    this.notes,
    required this.totalAmount,
    this.user,
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      status: BookingStatusExtension.fromString(json['status'] ?? 'PENDING'),
      scheduledDate: DateTime.parse(json['scheduledDate'] ?? DateTime.now().toIso8601String()),
      address: json['address'] ?? '',
      notes: json['notes'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
    );
  }
}
