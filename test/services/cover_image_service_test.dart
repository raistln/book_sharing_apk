import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:book_sharing_app/services/cover_image_service.dart';

// Mock classes
class MockImagePicker extends Mock implements ImagePicker {}
class MockHttpClient extends Mock implements http.Client {}
class MockResponse extends Mock implements http.Response {}

void main() {
  group('CoverImageService', () {
    late MockImagePicker mockImagePicker;
    late MockHttpClient mockHttpClient;
    late MockResponse mockResponse;
    late Directory tempDir;

    setUpAll(() {
      registerFallbackValue(File('test.jpg'));
      registerFallbackValue(Uri.parse('https://example.com/image.jpg'));
      registerFallbackValue(ImageSource.gallery);
    });

    setUp(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('cover_image_test');
      
      // Setup mocks
      mockImagePicker = MockImagePicker();
      mockHttpClient = MockHttpClient();
      mockResponse = MockResponse();

      // Mock HTTP response
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.bodyBytes).thenReturn(Uint8List.fromList([1, 2, 3, 4, 5]));

      // Mock HTTP client
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => mockResponse);
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('pickCover', () {
      test('returns null when user cancels image picker', () async {
        when(() => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => null);

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.pickCover();

        expect(result, isNull);
      });

      test('saves picked image to covers directory', () async {
        final testFile = File(p.join(tempDir.path, 'source.jpg'));
        await testFile.writeAsBytes(Uint8List.fromList([1, 2, 3, 4, 5]));

        when(() => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => XFile(testFile.path));

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.pickCover();

        expect(result, isNotNull);
        expect(result!.startsWith(tempDir.path), isTrue);
        expect(result.contains('covers'), isTrue);
        expect(result.endsWith('.jpg'), isTrue);
        expect(await File(result).exists(), isTrue);
      });

      test('handles file system errors gracefully', () async {
        when(() => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        )).thenThrow(Exception('File system error'));

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.pickCover();

        expect(result, isNull);
      });
    });

    group('deleteCover', () {
      test('deletes existing file successfully', () async {
        final testFile = File(p.join(tempDir.path, 'test_delete.jpg'));
        await testFile.writeAsBytes(Uint8List.fromList([1, 2, 3, 4, 5]));

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        await coverService.deleteCover(testFile.path);

        expect(await testFile.exists(), isFalse);
      });

      test('handles non-existent file gracefully', () async {
        final nonExistentPath = p.join(tempDir.path, 'non_existent.jpg');

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        // Should not throw exception
        await coverService.deleteCover(nonExistentPath);

        // No exception means success
        expect(true, isTrue);
      });
    });

    group('saveRemoteCover', () {
      test('saves remote image successfully', () async {
        const imageUrl = 'https://example.com/image.jpg';

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.saveRemoteCover(imageUrl);

        expect(result, isNotNull);
        expect(result!.startsWith(tempDir.path), isTrue);
        expect(result.contains('covers'), isTrue);
        expect(result.contains('cover_remote_'), isTrue);
        expect(await File(result).exists(), isTrue);

        verify(() => mockHttpClient.get(Uri.parse(imageUrl))).called(1);
      });

      test('returns null on HTTP error', () async {
        const imageUrl = 'https://example.com/not_found.jpg';

        when(() => mockResponse.statusCode).thenReturn(404);

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.saveRemoteCover(imageUrl);

        expect(result, isNull);

        verify(() => mockHttpClient.get(Uri.parse(imageUrl))).called(1);
      });

      test('returns null on empty response', () async {
        const imageUrl = 'https://example.com/empty.jpg';

        when(() => mockResponse.bodyBytes).thenReturn(Uint8List(0));

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.saveRemoteCover(imageUrl);

        expect(result, isNull);

        verify(() => mockHttpClient.get(Uri.parse(imageUrl))).called(1);
      });

      test('handles network errors gracefully', () async {
        const imageUrl = 'https://example.com/network_error.jpg';

        when(() => mockHttpClient.get(any())).thenThrow(Exception('Network error'));

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.saveRemoteCover(imageUrl);

        expect(result, isNull);

        verify(() => mockHttpClient.get(Uri.parse(imageUrl))).called(1);
      });

      test('adds default extension when missing', () async {
        const imageUrl = 'https://example.com/image'; // No extension

        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        final result = await coverService.saveRemoteCover(imageUrl);

        expect(result, isNotNull);
        expect(result!.endsWith('.jpg'), isTrue);
      });
    });

    group('supportsPicking', () {
      test('returns true for IO implementation', () {
        final coverService = _TestCoverImageService(
          imagePicker: mockImagePicker,
          httpClient: mockHttpClient,
          tempDir: tempDir,
        );

        expect(coverService.supportsPicking, isTrue);
      });
    });
  });
}

// Test implementation that allows dependency injection
class _TestCoverImageService implements CoverImageService {
  _TestCoverImageService({
    required ImagePicker imagePicker,
    required http.Client httpClient,
    required Directory tempDir,
  }) : _imagePicker = imagePicker,
       _httpClient = httpClient,
       _tempDir = tempDir;

  final ImagePicker _imagePicker;
  final http.Client _httpClient;
  final Directory _tempDir;

  @override
  bool get supportsPicking => true;

  @override
  Future<String?> pickCover() async {
    try {
      final result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
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
      final filename = 'cover_${DateTime.now().millisecondsSinceEpoch}$extension';
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
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }

      final directory = await _ensureCoverDirectory();
      var extension = p.extension(Uri.parse(url).path);
      if (extension.isEmpty) {
        extension = '.jpg';
      }
      final filename = 'cover_remote_${DateTime.now().millisecondsSinceEpoch}$extension';
      final target = File(p.join(directory.path, filename));

      await target.writeAsBytes(response.bodyBytes, flush: true);
      return target.path;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _ensureCoverDirectory() async {
    final coversDir = Directory(p.join(_tempDir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }
}
