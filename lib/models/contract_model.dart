class ContractPartyModel {
  const ContractPartyModel({this.id, this.nombre, this.email});

  final String? id;
  final String? nombre;
  final String? email;

  factory ContractPartyModel.fromJson(dynamic value) {
    if (value is! Map) return const ContractPartyModel();
    return ContractPartyModel(
      id: value['id']?.toString(),
      nombre: value['nombre']?.toString() ?? value['name']?.toString(),
      email: value['email']?.toString(),
    );
  }

  String get displayName =>
      nombre?.trim().isNotEmpty == true ? nombre! : email ?? 'Sin nombre';
}

class ContractCommentModel {
  const ContractCommentModel({
    required this.by,
    required this.body,
    this.createdAt,
  });

  final ContractPartyModel by;
  final String body;
  final DateTime? createdAt;

  factory ContractCommentModel.fromJson(Map<String, dynamic> json) {
    return ContractCommentModel(
      by: ContractPartyModel.fromJson(json['by'] ?? json['author']),
      body: (json['body'] ?? '').toString(),
      createdAt: ContractModel._toDate(json['createdAt']),
    );
  }
}

class ContractPhotoModel {
  const ContractPhotoModel({
    required this.by,
    required this.url,
    required this.description,
    this.createdAt,
  });

  final ContractPartyModel by;
  final String url;
  final String description;
  final DateTime? createdAt;

  factory ContractPhotoModel.fromJson(Map<String, dynamic> json) {
    return ContractPhotoModel(
      by: ContractPartyModel.fromJson(json['by'] ?? json['author']),
      url: (json['url'] ?? json['photo'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: ContractModel._toDate(json['createdAt']),
    );
  }
}

class ContractModel {
  const ContractModel({
    required this.id,
    this.offerId,
    this.jobTypeName,
    this.contratante,
    this.contratado,
    this.myRole,
    this.salary,
    this.currency,
    this.startDate,
    this.duration,
    required this.status,
    this.createdAt,
    this.acceptedAt,
    this.cancelJustification,
    this.cancelledBy,
    this.cancelledAt,
    this.comments = const [],
    this.photos = const [],
  });

  final String id;
  final String? offerId;
  final String? jobTypeName;
  final ContractPartyModel? contratante;
  final ContractPartyModel? contratado;
  final String? myRole;
  final double? salary;
  final String? currency;
  final DateTime? startDate;
  final String? duration;
  final String status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final String? cancelJustification;
  final ContractPartyModel? cancelledBy;
  final DateTime? cancelledAt;
  final List<ContractCommentModel> comments;
  final List<ContractPhotoModel> photos;

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: (json['id'] ?? '').toString(),
      offerId: json['offerId']?.toString(),
      jobTypeName: json['jobTypeName']?.toString(),
      contratante: json['contratante'] == null
          ? null
          : ContractPartyModel.fromJson(json['contratante']),
      contratado: json['contratado'] == null
          ? null
          : ContractPartyModel.fromJson(json['contratado']),
      myRole: json['myRole']?.toString(),
      salary: _toDouble(json['salary']),
      currency: json['currency']?.toString(),
      startDate: _toDate(json['startDate']),
      duration: json['duration']?.toString(),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: _toDate(json['createdAt']),
      acceptedAt: _toDate(json['acceptedAt']),
      cancelJustification: json['cancelJustification']?.toString(),
      cancelledBy: json['cancelledBy'] == null
          ? null
          : ContractPartyModel.fromJson(json['cancelledBy']),
      cancelledAt: _toDate(json['cancelledAt']),
      comments: _mapList(json['comments'], ContractCommentModel.fromJson),
      photos: _mapList(json['photos'], ContractPhotoModel.fromJson),
    );
  }

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isFinished => status == 'cancelled' || status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'rejected':
        return 'Rechazado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Pendiente';
    }
  }

  ContractPartyModel? get otherParty {
    return myRole == 'contratado' ? contratante : contratado;
  }

  static List<T> _mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList();
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDate(dynamic value) {
    return value == null ? null : DateTime.tryParse(value.toString());
  }
}
