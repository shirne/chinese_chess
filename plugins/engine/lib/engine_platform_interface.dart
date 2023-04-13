import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'engine_method_channel.dart';

abstract class EnginePlatform extends PlatformInterface {
  /// Constructs a EnginePlatform.
  EnginePlatform() : super(token: _token);

  static final Object _token = Object();

  static EnginePlatform _instance = MethodChannelEngine();

  /// The default instance of [EnginePlatform] to use.
  ///
  /// Defaults to [MethodChannelEngine].
  static EnginePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EnginePlatform] when
  /// they register themselves.
  static set instance(EnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getEnginePath() {
    throw UnimplementedError('enginePath() has not been implemented.');
  }

  Future<bool?> init(){
     throw UnimplementedError('init() has not been implemented.');
  }
}
