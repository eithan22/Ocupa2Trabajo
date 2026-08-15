/// Representación mínima de una oferta dentro de "Me gusta" (GET /me/likes).
///
/// El modelo completo de oferta (`OfferModel`) es propiedad de Persona 2 y
/// vive en `lib/models/offer_model.dart`. Este modelo local solo existe para
/// que `liked_offers_screen.dart` pueda compilar y mostrarse de forma
/// independiente mientras P2 termina su parte.
///
/// 🔁 Acción pendiente de integración: cuando `OfferModel` de P2 esté listo,
/// reemplaza este archivo — usa `OfferModel.fromJson` en su lugar y borra
/// esta clase, para no mantener dos representaciones de "oferta".
class LikedOfferModel {
  final String id;
  final String title;
  final String? photoUrl;
  final String? jobTypeName;

  LikedOfferModel({
    required this.id,
    required this.title,
    this.photoUrl,
    this.jobTypeName,
  });

  factory LikedOfferModel.fromJson(Map<String, dynamic> json) {
    return LikedOfferModel(
      id: (json['id'] ?? json['offerId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      photoUrl: json['photoUrl'] ?? json['photo'],
      jobTypeName: json['jobTypeName'] ?? json['jobType']?['name'],
    );
  }
}
