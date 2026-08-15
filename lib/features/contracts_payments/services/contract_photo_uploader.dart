import 'package:image_picker/image_picker.dart';

import 'contract_photo_uploader_stub.dart'
    if (dart.library.io) 'contract_photo_uploader_io.dart'
    if (dart.library.html) 'contract_photo_uploader_web.dart';

Future<String> uploadContractPhoto(XFile file) =>
    uploadContractPhotoPlatform(file);
