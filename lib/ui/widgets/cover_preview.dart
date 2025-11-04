import 'package:flutter/material.dart';

import 'cover_preview_stub.dart'
    if (dart.library.io) 'cover_preview_io.dart';

Widget buildCoverPreview(
  String? path, {
  double size = 48,
  BorderRadius? borderRadius,
}) {
  final radius = borderRadius ?? BorderRadius.circular(8);
  return buildCoverPreviewImpl(
    path,
    size: size,
    borderRadius: radius,
  );
}
