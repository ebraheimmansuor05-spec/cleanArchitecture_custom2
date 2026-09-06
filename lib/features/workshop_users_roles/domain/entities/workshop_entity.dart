import 'package:equatable/equatable.dart';

class WorkshopEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkshopEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        createdAt,
        updatedAt,
      ];
}