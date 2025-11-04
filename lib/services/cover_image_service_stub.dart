import 'cover_image_service_base.dart';

class _CoverImageServiceStub implements CoverImageService {
  const _CoverImageServiceStub();

  @override
  bool get supportsPicking => false;

  @override
  Future<String?> pickCover() async => null;

  @override
  Future<void> deleteCover(String path) async {}

  @override
  Future<String?> saveRemoteCover(String url) async => null;
}

CoverImageService buildCoverImageService() => const _CoverImageServiceStub();
