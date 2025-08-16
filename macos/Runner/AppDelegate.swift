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
  override func application(_ sender: NSApplication, open urls: [URL]) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

    let channel = FlutterMethodChannel(
      name: "cn.leo/fileOpen",
      binaryMessenger: controller.engine.binaryMessenger
    )
    // 将 URL 数组转换为文件路径字符串数组
    let filePaths = urls.map { $0.path }

    // 确保在主线程中调用
    DispatchQueue.main.async {
      channel.invokeMethod("openFile", arguments: filePaths)
    }
//     showMessage(question: "application", text: "urls = " + urls.description)
  }

//   func showMessage(question: String, text: String) {
//     let alert = NSAlert()
//     alert.messageText = question
//     alert.informativeText = text
//     alert.addButton(withTitle: "OK")
//     alert.alertStyle = .warning
//     alert.runModal()
//   }
}
