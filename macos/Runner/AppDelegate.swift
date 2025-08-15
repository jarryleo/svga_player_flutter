import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    NSApp.activate(ignoringOtherApps: true)
    return true
  }

  // 处理文件打开事件
  override func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

    let channel = FlutterMethodChannel(
      name: "cn.leo/fileOpen",
      binaryMessenger: controller.engine.binaryMessenger
    )

    // 确保在主线程中调用
    DispatchQueue.main.async {
      channel.invokeMethod("openFile", arguments: filename)
    }

    return true
  }
}
