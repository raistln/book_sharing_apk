abstract class CoverImageService {
  bool get supportsPicking;

  Future<String?> pickCover();

  Future<String?> pickCoverFromCamera();

  Future<void> deleteCover(String path);

  Future<String?> saveRemoteCover(String url);
}
