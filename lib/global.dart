import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

export 'utils/core.dart';
export 'theme.dart';

final isWindow =
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

final logger = Logger('LOG')
  ..onRecord.listen((record) {
    if (kDebugMode && record.error != null) {
      FlutterError.presentError(
        FlutterErrorDetails(
          exception: record.error!,
          stack: record.stackTrace,
        ),
      );
    } else {
      dev.log(
        record.message,
        name: '${record.loggerName} ${levelMoji(record.level)}',
        time: record.time,
        level: record.level.value,
        error: record.error,
        stackTrace: record.stackTrace,
        sequenceNumber: record.sequenceNumber,
      );
    }
  });

String levelMoji(Level lv) {
  switch (lv.value) {
    case 0:
      break;
    case 300: //Level.FINEST:
      return '🎉';
    case 400: //Level.FINER:
      return '✨';
    case 500: //Level.FINE:
      return '✅';
    case 700: //Level.CONFIG:
      return '🔧';
    case 800: //Level.INFO:
      return '💡';
    case 900: //Level.WARNING:
      return '⚠️';
    case 1000: //Level.SEVERE:
      return '❌';
    case 1200: //Level.SHOUT:
      return '💥';
    case 2000: //Level.OFF:
      return '⛔';
  }
  return '♻️';
}
