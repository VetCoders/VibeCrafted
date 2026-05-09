import Cocoa

class MainSplitViewController: NSSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sidebar = NSSplitViewItem(sidebarWithViewController: SidebarViewController())
        let canvas = NSSplitViewItem(viewController: CanvasViewController())
        let inspector = NSSplitViewItem(viewController: InspectorViewController())
        
        sidebar.minimumThickness = 200
        canvas.minimumThickness = 400
        inspector.minimumThickness = 250
        
        self.addSplitViewItem(sidebar)
        self.addSplitViewItem(canvas)
        self.addSplitViewItem(inspector)
    }
}
