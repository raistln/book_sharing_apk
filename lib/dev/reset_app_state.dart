import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final messages = <String>[];
  void logStep(String message) {
    developer.log(message, name: 'ResetScript');
    messages.add(message);
  }

  final warnings = <String>[];

  logStep('Iniciando reseteo de estado local...');

  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys().toList(growable: false);
  if (keys.isNotEmpty) {
    logStep('Eliminando ${keys.length} claves de SharedPreferences');
    await prefs.clear();
  } else {
    logStep('SharedPreferences ya estaba vacío');
  }

  const secureStorage = FlutterSecureStorage();
  try {
    logStep('Vaciando FlutterSecureStorage');
    await secureStorage.deleteAll();
  } catch (error, stackTrace) {
    const message =
        'No se pudo limpiar FlutterSecureStorage automáticamente. Limpia la credencial manualmente.';
    developer.log(message, name: 'ResetScript', error: error, stackTrace: stackTrace);
    warnings.add('$message\n$error');
  }

  final appDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(appDir.path, 'book_sharing.sqlite'));
  if (await dbFile.exists()) {
    logStep('Borrando base de datos local: ${dbFile.path}');
    await dbFile.delete();
  } else {
    logStep('No se encontró base de datos en ${dbFile.path}');
  }

  if (await appDir.exists()) {
    logStep('Eliminando directorio de datos: ${appDir.path}');
    try {
      await appDir.delete(recursive: true);
    } catch (error, stackTrace) {
      const message =
          'No se pudo eliminar el directorio completo. Puedes borrarlo manualmente.';
      developer.log(message, name: 'ResetScript', error: error, stackTrace: stackTrace);
      warnings.add('$message\n$error');
    }
  }

  logStep('Reseteo completado. Puedes cerrar esta ventana.');

  runApp(_ResetSummaryApp(messages: messages, warnings: warnings));
}

class _ResetSummaryApp extends StatelessWidget {
  const _ResetSummaryApp({required this.messages, required this.warnings});

  final List<String> messages;
  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Reset completado')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revisa los pasos ejecutados. Cuando cierres esta ventana, puedes lanzar la app normalmente.',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...messages.map((m) => _MessageTile(message: m)),
                    if (warnings.isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Avisos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...warnings.map((w) => _MessageTile(message: w, isWarning: true)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => exit(0),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, this.isWarning = false});

  final String message;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).textTheme.bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        message,
        style: TextStyle(color: color),
      ),
    );
  }
}
