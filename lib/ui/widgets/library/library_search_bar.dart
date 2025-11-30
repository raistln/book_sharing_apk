import 'package:flutter/material.dart';

class LibrarySearchBar extends StatefulWidget {
  const LibrarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Buscar por título o autor...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  setState(() => _searchQuery = '');
                  widget.onChanged('');
                },
              )
            : null,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
        widget.onChanged(value);
      },
    );
  }
}
