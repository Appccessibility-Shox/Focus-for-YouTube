//
//  ViewController.swift
//  Focus for YouTube
//
//  Created by Patrick Botros on 5/20/20.
//  Copyright © 2020 Patrick Botros. All rights reserved.
//

import Cocoa
import SafariServices

let defaults = UserDefaults.standard
let appGroupID: String = "L27L4K8SQU.Focus4YouTube"
let contentBlockerID: String = "shockerella.Focus-for-YouTube.Content-Blocker"


enum actions: String {
    case block = "block"
    case css = "css-display-none"
}

typealias SwiftyBlockingRule = [String: [String: Any]]
typealias SwiftyJSON = [SwiftyBlockingRule]

class BlockableElement {
    let elementName, selector: String
    var blocked: Bool
    init(named: String, blocked: Bool, selector: String) {
        self.elementName = named
        self.selector = selector
        self.blocked = blocked
    }
}

// Manually ensure these default block properties match the defaultBlockList.json.
var blockableElements: [BlockableElement] = [
     BlockableElement(named: "Homepage Recommendations", blocked: true, selector: "ytd-two-column-browse-results-renderer[page-subtype='home'] #primary"),
     BlockableElement(named: "Endscreen Video Wall", blocked: true, selector: ".ytp-endscreen-content, button.ytp-endscreen-previous, button.ytp-endscreen-next, .ytp-ce-element.ytp-ce-element-show"),
     BlockableElement(named: "Trending Videos", blocked: true, selector: "a[href='/feed/trending']"),
     BlockableElement(named: "Related Videos Sidebar", blocked: true, selector: "div#related"),
     BlockableElement(named: "Comments", blocked: false, selector: "ytd-comments#comments.style-scope.ytd-watch-flexy"),
     BlockableElement(named: "Merch Shelf", blocked: true, selector: "div#merch-shelf"),
     BlockableElement(named: "Ticket Shelf", blocked: true, selector: "div#ticket-shelf"),
     BlockableElement(named: "Masthead Buttons", blocked: false, selector: "div#buttons"),
     BlockableElement(named: "Details and Likes Bar", blocked: false, selector: "div#info"),
     BlockableElement(named: "Description", blocked: false, selector: "ytd-expander.ytd-video-secondary-info-renderer")
]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, DOMElementCellDelegate {

    @IBOutlet weak var tableView: NSTableView!

    @IBAction func openIssuePage(_ sender: Any) {
        NSWorkspace.shared.open(NSURL(string: "https://github.com/patrickshox/Focus-for-YouTube/issues")! as URL)
    }

    @IBAction func openSafariExtensionPreferences(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: contentBlockerID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // reload with user's custom block preferences.
        for blockListitem in blockableElements where defaults.object(forKey: blockListitem.elementName) != nil {
            blockListitem.blocked = defaults.bool(forKey: blockListitem.elementName)
        }
        tableView.reloadData()
    }

    var commaSeparatedSelectorsToBlock = ""

    func updateDataSource(blocked: Bool, index: Int) {
        blockableElements[index].blocked = blocked
        var selectorsToBlock: [String] = []
        for elementIndex in 0...blockableElements.count-1 where blockableElements[elementIndex].blocked {
            selectorsToBlock.append(blockableElements[elementIndex].selector)
        }
        commaSeparatedSelectorsToBlock = selectorsToBlock.joined(separator: ", ")
        tableView.reloadData()
    }

    func updateBlockListJSON() {

        let blockList: SwiftyJSON =
            [
                [
                    "trigger": [
                        "url-filter": "https://www.youtube.com.*"
                    ],
                    "action": [
                        "type": "css-display-none",
                        "selector": commaSeparatedSelectorsToBlock
                    ]
                ]
            ]

        let blockListJSON = try? JSONSerialization.data(withJSONObject: blockList, options: .prettyPrinted)

        let appGroupPathname = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!

        let blockListJSONfileLocation = appGroupPathname.appendingPathComponent("blockList.json")

        try? blockListJSON!.write(to: blockListJSONfileLocation)

        SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerID, completionHandler: { error in
            print(error ?? "🔄 Blocker reload success.")
        })
    }
}

// Basic tableView set up functions.
extension ViewController {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return blockableElements.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let domElementReuseID = NSUserInterfaceItemIdentifier(rawValue: "domElementIdentifier")
        if let cell = tableView.makeView(withIdentifier: domElementReuseID, owner: nil) as? BlockableElementRow {
            if blockableElements[row].blocked {
                cell.checkBoxImage.image = NSImage(named: "checked")
            } else {
                cell.checkBoxImage.image = NSImage(named: "unchecked")
            }
            cell.elementName = blockableElements[row].elementName
            cell.elementNameLabel?.stringValue = blockableElements[row].elementName
            cell.containingViewController = self
            cell.rowNumber = row
            cell.blockableElements = blockableElements

            return cell
        }
        return nil
    }
}

// aesthetics 👨🏻‍🎨
class ColoredView: NSView {
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor(named: "background_color")?.cgColor
    }
}

// aesthetics 👨🏻‍🎨
extension ViewController {
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.isMovableByWindowBackground = true
        tableView.rowHeight = 33
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .none
    }
}

