import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../cover_preview.dart';

/// Cover field widget for book form
class CoverField extends StatelessWidget {
  const CoverField({
    super.key,
    required this.coverPath,
    required this.pickingSupported,
    this.onPick,
    this.onPickFromCamera,
    this.onRemove,
  });

  final String? coverPath;
  final bool pickingSupported;
  final Future<void> Function()? onPick;
  final Future<void> Function()? onPickFromCamera;
  final Future<void> Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildCoverPreview(
          coverPath,
          size: 72,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coverPath == null ? S.of(context).coverNoCover : S.of(context).coverSelected,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                coverPath ??
                    S.of(context).coverHelp,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (pickingSupported) ...[
                    FilledButton.tonalIcon(
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: Text(S.of(context).coverGallery),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onPickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: Text(S.of(context).coverCamera),
                    ),
                  ],
                  if (!pickingSupported)
                    Chip(
                      avatar: const Icon(Icons.info_outline, size: 18),
                      label: Text(S.of(context).coverNotAvailable),
                    ),
                  if (coverPath != null && onRemove != null)
                    OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(S.of(context).coverDelete),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
