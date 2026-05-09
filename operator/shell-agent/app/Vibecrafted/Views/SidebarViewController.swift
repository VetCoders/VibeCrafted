import Cocoa

class SidebarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let tableView = NSTableView()
    var servers: [FfiServerStatus] = []
    
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
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ServerColumn"))
        column.title = "Servers"
        tableView.addTableColumn(column)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerView = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEvent), name: NSNotification.Name("IpcEvent"), object: nil)
        
        refreshServers()
    }
    
    @objc func handleEvent(_ notification: Notification) {
        refreshServers()
    }
    
    func refreshServers() {
        Task {
            do {
                let status = try await getServerStatus()
                DispatchQueue.main.async {
                    self.servers = status
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to get servers: \(error)")
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return servers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let server = servers[row]
        let cellIdentifier = NSUserInterfaceItemIdentifier("ServerCell")
        var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTextField
        
        if cell == nil {
            cell = NSTextField(labelWithString: "")
            cell?.identifier = cellIdentifier
        }
        
        let glyph = server.status == "Idle" ? "🟢" : (server.status == "Failed" ? "🔴" : "🟡")
        cell?.stringValue = "\(glyph) \(server.name)"
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let server = servers[selectedRow]
            NotificationCenter.default.post(name: NSNotification.Name("SelectedServerChanged"), object: server.name)
        }
    }
}
