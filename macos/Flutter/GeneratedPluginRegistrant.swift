//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import file_selector_macos
import screen_retriever
import shared_preferences_macos
import soundpool_macos
import soundpool_windux
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SwiftSoundpoolPlugin.register(with: registry.registrar(forPlugin: "SwiftSoundpoolPlugin"))
  SoundpoolWinduxPlugin.register(with: registry.registrar(forPlugin: "SoundpoolWinduxPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
