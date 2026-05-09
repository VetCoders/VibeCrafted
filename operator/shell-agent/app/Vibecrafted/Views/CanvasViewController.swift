import Cocoa

class CanvasViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let tableView = NSTableView()
    var routes: [FfiRoute] = []
    
    override func loadView() {
        self.view = NSView()
        
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        
        self.view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let col1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Client"))
        col1.title = "Client"
        tableView.addTableColumn(col1)
        
        let col2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Service"))
        col2.title = "Service"
        tableView.addTableColumn(col2)
        
        let col3 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("State"))
        col3.title = "State"
        tableView.addTableColumn(col3)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: NSNotification.Name("IpcEvent"), object: nil)
        
        refreshRoutes()
    }
    
    @objc func handleEvent(_ notification: Notification) {
        refreshRoutes()
    }
    
    func refreshRoutes() {
        Task {
            do {
                let status = try await getRoutes()
                DispatchQueue.main.async {
                    self.routes = status
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to get routes: \(error)")
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let route = routes[row]
        let cellIdentifier = NSUserInterfaceItemIdentifier("RouteCell")
        var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTextField
        
        if cell == nil {
            cell = NSTextField(labelWithString: "")
            cell?.identifier = cellIdentifier
        }
        
        if tableColumn?.identifier.rawValue == "Client" {
            cell?.stringValue = String(describing: route.client)
        } else if tableColumn?.identifier.rawValue == "Service" {
            cell?.stringValue = route.service
        } else {
            cell?.stringValue = route.state
        }
        
        return cell
    }
}
