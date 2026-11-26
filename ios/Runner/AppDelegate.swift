import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeAppDataFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// The database (My List, tastes, the onboarding flag) stays on this device:
  /// an iCloud/iTunes restore must not bring back a finished onboarding.
  private func excludeAppDataFromBackup() {
    let fm = FileManager.default
    for dir in [FileManager.SearchPathDirectory.documentDirectory, .applicationSupportDirectory] {
      guard var url = fm.urls(for: dir, in: .userDomainMask).first else { continue }
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try? url.setResourceValues(values)
    }
  }
}
