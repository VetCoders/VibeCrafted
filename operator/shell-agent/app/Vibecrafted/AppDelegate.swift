import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowController = MainWindowController()
        windowController.showWindow(self)
        self.mainWindowController = windowController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
