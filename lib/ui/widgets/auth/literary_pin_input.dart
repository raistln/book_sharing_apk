import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A literary-themed PIN input widget that visualizes the "key" to the library.
/// Instead of a generic text field, it presents a sequence of "illuminated" slots.
class LiteraryPinInput extends StatefulWidget {
  const LiteraryPinInput({
    super.key,
    required this.controller,
    this.length = 4, // Default changed to 4 per user request
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;
  final VoidCallback? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<LiteraryPinInput> createState() => _LiteraryPinInputState();
}

class _LiteraryPinInputState extends State<LiteraryPinInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final text = widget.controller.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call();
    }
    setState(() {}); // Rebuild to update dots
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Invisible Text Field for handling input
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              showCursor: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              selectionControls: EmptyTextSelectionControls(), // Prevent menu
            ),
          ),
          // Visual representation
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (index) {
              final isFilled = index < text.length;
              final isFocused = index == text.length && _focusNode.hasFocus;

              return _PinDigitSlot(
                index: index,
                isFilled: isFilled,
                isFocused: isFocused,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PinDigitSlot extends StatelessWidget {
  const _PinDigitSlot({
    required this.index,
    required this.isFilled,
    required this.isFocused,
  });

  final int index;
  final bool isFilled;
  final bool isFocused;

  // Runas del Elder Futhark para dar ambiente
  static const _runes = ['ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final runeChar = _runes[index % _runes.length];

    // We use AnimatedContainer for smooth transitions between states
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      margin:
          const EdgeInsets.symmetric(horizontal: 10), // Más espacio entre ellos
      height: 56, // Círculos más grandes
      width: 56,
      decoration: BoxDecoration(
        color: isFilled
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isFocused ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: isFilled
            ? [
                // Halo / Sombra detrás cuando está lleno
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedOpacity(
          opacity: isFilled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            runeChar,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
              fontFamily:
                  'NotoSansRunic', // Fallback to compatible font if needed, usually system handles unicode
            ),
          ),
        ),
      ),
    );
  }
}
