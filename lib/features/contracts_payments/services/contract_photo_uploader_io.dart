import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../core/services/upload_service.dart';

Future<String> uploadContractPhotoPlatform(XFile file) {
  return UploadService().uploadImage(File(file.path));
}
