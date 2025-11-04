import 'package:flutter/material.dart';

Widget buildCoverPreviewImpl(
  String? path, {
  double size = 48,
  BorderRadius? borderRadius,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      color: Colors.grey.shade300,
    ),
    child: const Icon(Icons.image_outlined),
  );
}
