import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize UniFFI runtime
        do {
            let socketPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".rust-mux/ipc/control.sock").path
            try initRuntime(socketPath: socketPath)
            
            // Start event stream
            let eventStream = AppEventCallback()
            Task {
                try? await subscribeEvents(callback: eventStream)
            }
        } catch {
            print("Failed to init runtime: \(error)")
        }

        let mainWC = MainWindowController()
        mainWC.showWindow(self)
        self.mainWindowController = mainWC
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

class AppEventCallback: EventCallback {
    func onEvent(eventJson: String) {
        // Post notification to update UI
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("IpcEvent"), object: eventJson)
        }
    }
    
    func onError(err: String) {
        print("Event error: \(err)")
    }
}