//
//  BlockableElementRow.swift
//  Focus for YouTube
//
//  Created by Patrick Botros on 5/20/20.
//  Copyright © 2020 Patrick Botros. All rights reserved.
//

import Cocoa

protocol DOMElementCellDelegate: class {
    func updateDataSource(blocked: Bool, index: Int)
    func updateBlockListJSON()
}

class ChecklistRow: NSTableRowView {
    var elementName: String?
    var rowNumber: Int?
    weak var containingViewController: DOMElementCellDelegate?
    var blockableElements: [BlockableElement]?

    @IBAction func checkBoxClicked(_ sender: Any) {
        if blockableElements![rowNumber!].blocked {
            containingViewController?.updateDataSource(blocked: false, index: rowNumber!)
            containingViewController?.updateBlockListJSON()
            defaults.set(false, forKey: elementName!)
        } else {
            containingViewController?.updateDataSource(blocked: true, index: rowNumber!)
            containingViewController?.updateBlockListJSON()
            defaults.set(true, forKey: elementName!)
        }
    }
    @IBOutlet weak var checkBoxImage: NSButton!
    @IBOutlet weak var elementNameLabel: NSTextFieldCell!
}
