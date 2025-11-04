import 'cover_image_service_base.dart';
import 'cover_image_service_stub.dart'
    if (dart.library.io) 'cover_image_service_io.dart';

export 'cover_image_service_base.dart';

CoverImageService createCoverImageService() => buildCoverImageService();
