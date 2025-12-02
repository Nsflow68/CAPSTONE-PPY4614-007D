import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? rut;
  final DateTime? birthDate;
  final String? gender;
  final String? registrationNumber;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.rut,
    this.birthDate,
    this.gender,
    this.registrationNumber,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      rut: json['rut'] as String?,
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate'] as String) 
          : null,
      gender: json['gender'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'rut': rut,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'registrationNumber': registrationNumber,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? rut,
    DateTime? birthDate,
    String? gender,
    String? registrationNumber,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      rut: rut ?? this.rut,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        rut,
        birthDate,
        gender,
        registrationNumber,
        role,
        createdAt,
        updatedAt,
      ];
}
