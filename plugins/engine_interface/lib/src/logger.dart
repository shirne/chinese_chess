import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final logger = Logger.root
  ..level = kReleaseMode ? Level.WARNING : Level.ALL
  ..onRecord.listen((record) {
    log(
      record.message,
      time: record.time,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
      sequenceNumber: record.sequenceNumber,
    );
  });
