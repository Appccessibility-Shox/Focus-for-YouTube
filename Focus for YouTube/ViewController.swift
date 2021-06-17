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

typealias SwiftyJSON = [SwiftyRule]

class BlockableElement {
    let elementName: String
    let rules: [BlockerRule]
    var blocked: Bool
    init(withName name: String, andRules rules: [BlockerRule], isBlockedByDefault blocked: Bool) {
        self.elementName = name
        self.rules = rules
        self.blocked = blocked
    }
    convenience init(withName name: String, andRule rule: BlockerRule, isBlockedByDefault blocked: Bool) {
        self.init(withName: name, andRules: [rule], isBlockedByDefault: blocked)
    }
}

// Manually ensure these default block properties match the defaultBlockList.json.
var blockableElements: [BlockableElement] = [
    BlockableElement(withName: "Homepage Recommendations", andRule: BlockerRule(selector: "ytd-two-column-browse-results-renderer[page-subtype='home'] #primary"), isBlockedByDefault: true),
    BlockableElement(withName: "Endscreen Video Wall", andRule: BlockerRule(selector: ".ytp-endscreen-content, button.ytp-endscreen-previous, button.ytp-endscreen-next, .ytp-ce-element.ytp-ce-element-show"), isBlockedByDefault: true),
    BlockableElement(withName: "Trending Videos", andRules: [BlockerRule(selector: "a[href='/feed/trending']"), BlockerRule(triggers: [.urlFilter: "https?://www.youtube.com/feed/trending"], actionType: .block)], isBlockedByDefault: true),
    BlockableElement(withName: "Explore", andRules: [BlockerRule(selector: "a[href='/feed/explore']"), BlockerRule(triggers: [.urlFilter: "https?://www.youtube.com/feed/explore"], actionType: .block)], isBlockedByDefault: false),
    BlockableElement(withName: "Subscriptions", andRules: [BlockerRule(selector: "a[href='/feed/subscriptions']"), BlockerRule(triggers: [.urlFilter: "https?://www.youtube.com/feed/subscriptions"], actionType: .block)], isBlockedByDefault: false),
    BlockableElement(withName: "Notifications", andRule: BlockerRule(selector: "div.ytd-notification-topbar-button-renderer"), isBlockedByDefault: false),
    BlockableElement(withName: "Related Videos Sidebar", andRule: BlockerRule(selector: "div#related"), isBlockedByDefault: true),
    BlockableElement(withName: "Comments", andRule: BlockerRule(selector: "ytd-comments#comments.style-scope.ytd-watch-flexy"), isBlockedByDefault: false),
    BlockableElement(withName: "Merch Shelf", andRule: BlockerRule(selector: "div#merch-shelf"), isBlockedByDefault: true),
    BlockableElement(withName: "Ticket Shelf", andRule: BlockerRule(selector: "div#ticket-shelf"), isBlockedByDefault: true),
    BlockableElement(withName: "Masthead Buttons", andRule: BlockerRule(selector: "div#buttons"), isBlockedByDefault: false),
    BlockableElement(withName: "Details and Likes Bar", andRule: BlockerRule(selector: "div#info"), isBlockedByDefault: false),
    BlockableElement(withName: "Description", andRule: BlockerRule(selector: "ytd-expander.ytd-video-secondary-info-renderer"), isBlockedByDefault: false)
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

    var activeBlockingRules = [SwiftyRule]()

    func updateDataSource(blocked: Bool, index: Int) {
        blockableElements[index].blocked = blocked
        activeBlockingRules = [SwiftyRule]()
        for elementIndex in 0...blockableElements.count-1 where blockableElements[elementIndex].blocked {
            for rule in blockableElements[elementIndex].rules {
                activeBlockingRules.append(rule.asSwiftyRule())
            }
        }
        tableView.reloadData()
    }

    func updateBlockListJSON() {

        let blockListJSON = try? JSONSerialization.data(withJSONObject: activeBlockingRules, options: .prettyPrinted)

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
        if let cell = tableView.makeView(withIdentifier: domElementReuseID, owner: nil) as? ChecklistRow {
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

