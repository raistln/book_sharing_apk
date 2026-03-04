import 'package:flutter/material.dart';
import '../info_pop.dart';

class JoinByCodeDialog extends StatefulWidget {
  const JoinByCodeDialog({
    super.key,
    required this.onJoin,
    required this.title,
    required this.labelText,
    this.helperText,
    this.successMessage = '¡Te has unido exitosamente!',
  });

  final Future<void> Function(String code) onJoin;
  final String title;
  final String labelText;
  final String? helperText;
  final String successMessage;

  @override
  State<JoinByCodeDialog> createState() => _JoinByCodeDialogState();
}

class _JoinByCodeDialogState extends State<JoinByCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: widget.labelText,
                border: const OutlineInputBorder(),
                errorText: _errorText,
                helperText: widget.helperText,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un código';
                }
                return null;
              },
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _isSubmitting ? null : (_) => _handleSubmit(),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unirse'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final code = _codeController.text.trim();
      await widget.onJoin(code);
      if (mounted) {
        Navigator.of(context).pop();
        InfoPop.success(context, widget.successMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText = e.toString().contains('Exception:')
              ? e.toString().split('Exception:').last.trim()
              : 'El código no es válido o ya expiró. Verifícalo e intenta de nuevo.';
        });
      }
    }
  }
}
