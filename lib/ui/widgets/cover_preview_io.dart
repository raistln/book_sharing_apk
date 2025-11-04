import 'dart:io';

import 'package:flutter/material.dart';

Widget buildCoverPreviewImpl(
  String? path, {
  double size = 48,
  BorderRadius? borderRadius,
}) {
  final radius = borderRadius ?? BorderRadius.circular(8);

  if (path == null) {
    return _placeholder(size, radius);
  }

  final file = File(path);
  if (!file.existsSync()) {
    return _placeholder(size, radius);
  }

  return ClipRRect(
    borderRadius: radius,
    child: Image.file(
      file,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(size, radius),
    ),
  );
}

Widget _placeholder(double size, BorderRadius radius) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: radius,
      color: Colors.grey.shade300,
    ),
    child: Icon(
      Icons.image_outlined,
      size: size * 0.6,
      color: Colors.grey.shade600,
    ),
  );
}
