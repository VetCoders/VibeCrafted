import Cocoa

class SidebarViewController: NSViewController {
    override func loadView() {
        self.view = NSView()
        
        let label = NSTextField(labelWithString: "Sidebar (Server List)")
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
