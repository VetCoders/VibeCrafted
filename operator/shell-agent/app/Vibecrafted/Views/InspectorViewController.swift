import Cocoa

class InspectorViewController: NSViewController {
    let nameLabel = NSTextField(labelWithString: "No server selected")
    let actionButton = NSButton(title: "Restart Service", target: nil, action: nil)
    let verifyButton = NSButton(title: "Verify Clients", target: nil, action: nil)
    
    var selectedServer: String?
    
    override func loadView() {
        self.view = NSView()
        
        let stack = NSStackView(views: [nameLabel, actionButton, verifyButton])
        stack.orientation = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        actionButton.target = self
        actionButton.action = #selector(restartAction)
        
        verifyButton.target = self
        verifyButton.action = #selector(verifyAction)
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverSelected), name: NSNotification.Name("SelectedServerChanged"), object: nil)
    }
    
    @objc func serverSelected(_ notification: Notification) {
        if let name = notification.object as? String {
            self.selectedServer = name
            self.nameLabel.stringValue = name
        }
    }
    
    @objc func restartAction() {
        guard let name = selectedServer else { return }
        Task {
            do {
                try await restartService(name: name)
                print("Restarted \(name)")
            } catch {
                print("Failed to restart: \(error)")
            }
        }
    }
    
    @objc func verifyAction() {
        Task {
            do {
                let res = try await verifyClient(kind: .claude)
                print("Verify Claude: \(res.ok) \(res.detail)")
            } catch {
                print("Failed to verify: \(error)")
            }
        }
    }
}
