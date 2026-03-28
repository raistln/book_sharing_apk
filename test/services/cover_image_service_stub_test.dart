import 'package:book_sharing_app/services/cover_image_service_base.dart';
import 'package:book_sharing_app/services/cover_image_service_stub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CoverImageService service;

  setUp(() {
    service = buildCoverImageService();
  });

  group('CoverImageServiceStub', () {
    test('supportsPicking returns false', () {
      expect(service.supportsPicking, false);
    });

    test('pickCover returns null', () async {
      final result = await service.pickCover();
      expect(result, null);
    });

    test('pickCoverFromCamera returns null', () async {
      final result = await service.pickCoverFromCamera();
      expect(result, null);
    });

    test('deleteCover completes without error', () async {
      await expectLater(service.deleteCover('path'), completes);
    });

    test('saveRemoteCover returns null', () async {
      final result = await service.saveRemoteCover('url');
      expect(result, null);
    });
  });
}
