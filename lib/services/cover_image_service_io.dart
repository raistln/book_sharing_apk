import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'cover_image_service_base.dart';

class _CoverImageServiceIo implements CoverImageService {
  _CoverImageServiceIo({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool get supportsPicking => true;

  @override
  Future<String?> pickCover() async {
    return _pickCoverFromSource(ImageSource.gallery);
  }

  @override
  Future<String?> pickCoverFromCamera() async {
    return _pickCoverFromSource(ImageSource.camera);
  }

  Future<String?> _pickCoverFromSource(ImageSource source) async {
    try {
      final result = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (result == null) return null;

      final directory = await _ensureCoverDirectory();
      var extension = p.extension(result.path);
      if (extension.isEmpty) {
        extension = '.jpg';
      }
      final filename =
          'cover_${DateTime.now().millisecondsSinceEpoch}$extension';
      final target = File(p.join(directory.path, filename));

      final bytes = await result.readAsBytes();
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteCover(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Future<String?> saveRemoteCover(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }

      final directory = await _ensureCoverDirectory();
      var extension = p.extension(Uri.parse(url).path);
      if (extension.isEmpty) {
        extension = '.jpg';
      }
      final filename =
          'cover_remote_${DateTime.now().millisecondsSinceEpoch}$extension';
      final target = File(p.join(directory.path, filename));

      await target.writeAsBytes(response.bodyBytes, flush: true);
      return target.path;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _ensureCoverDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(docsDir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }
}

CoverImageService buildCoverImageService() => _CoverImageServiceIo();
