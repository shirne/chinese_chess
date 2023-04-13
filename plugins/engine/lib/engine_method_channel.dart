import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'engine_platform_interface.dart';

/// An implementation of [EnginePlatform] that uses method channels.
class MethodChannelEngine extends EnginePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('engine');

  @override
  Future<String?> getEnginePath() async {
    final path = await methodChannel.invokeMethod<String>('getEnginePath');
    return path;
  }

   @override
  Future<bool?> init()  {
    return methodChannel.invokeMethod<bool>('getEnginePath');
  }
}
