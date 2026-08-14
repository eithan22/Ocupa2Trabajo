/// Mapea 1:1 el schema `User` del API (ver `#/components/schemas/User` en
/// el OpenAPI de Ocupa2). La mayoría de campos de perfil son nulos hasta
/// que el usuario completa `PUT /me/profile`.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.nombre,
    this.cedula,
    this.gender,
    this.birthDate,
    this.profileCompleted = false,
    this.referralMatricula,
    this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nombre;
  final String? cedula;
  final String? gender;
  final DateTime? birthDate;
  final bool profileCompleted;
  final String? referralMatricula;
  final String? role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      nombre: json['nombre'] as String?,
      cedula: json['cedula'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      referralMatricula: json['referralMatricula'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (nombre != null) 'nombre': nombre,
      if (cedula != null) 'cedula': cedula,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      'profileCompleted': profileCompleted,
      if (referralMatricula != null) 'referralMatricula': referralMatricula,
      if (role != null) 'role': role,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
    };
  }
}
