import Cocoa

class MainWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Vibecrafted"
        window.minSize = NSSize(width: 800, height: 600)
        
        let toolbar = NSToolbar(identifier: "MainWindowToolbar")
        window.toolbar = toolbar
        
        self.init(window: window)
        self.contentViewController = MainSplitViewController()
    }
}
