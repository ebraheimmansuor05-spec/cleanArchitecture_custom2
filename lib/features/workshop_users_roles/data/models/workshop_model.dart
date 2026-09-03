import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_entity.dart';

class WorkshopModel extends WorkshopEntity {
  const WorkshopModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw FormatException('Invalid date format: $value');
  }
}