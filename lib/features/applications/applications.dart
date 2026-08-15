/// Barrel file del módulo "Aplicaciones y Experiencias" (Persona 3).
///
/// Permite que otros módulos (ej. Persona 2 embebiendo `ApplyToOfferWidget`
/// o `LikeButton`) hagan un solo import:
/// ```dart
/// import 'package:ocupa2/features/applications/applications.dart';
/// ```
library;

export 'data/applications_repository.dart';
export 'data/liked_offer_model.dart';
export 'providers/applications_provider.dart';
export 'presentation/applicants_list_screen.dart';
export 'presentation/applications_routes.dart';
export 'presentation/apply_to_offer_widget.dart';
export 'presentation/experiences_screen.dart';
export 'presentation/liked_offers_screen.dart';
export 'presentation/my_applications_screen.dart';
