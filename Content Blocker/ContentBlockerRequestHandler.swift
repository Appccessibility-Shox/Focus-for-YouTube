//
//  ContentBlockerRequestHandler.swift
//  Content Blocker
//
//  Created by Patrick Botros on 5/20/20.
//  Copyright © 2020 Patrick Botros. All rights reserved.
//

import Foundation

let appGroupID: String = "L27L4K8SQU.Focus4YouTube"

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

        func beginRequest(with context: NSExtensionContext) {
        let appGroupPathname = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let blocklistJSONFileLocation = appGroupPathname!.appendingPathComponent("blockList.json")
        let defaultBlockListFileLocation = Bundle.main.url(forResource: "defaultBlockerList", withExtension: "json")
        var attachment: NSItemProvider = NSItemProvider(contentsOf: defaultBlockListFileLocation)!
        if FileManager.default.fileExists(atPath: blocklistJSONFileLocation.path) {
            attachment = NSItemProvider(contentsOf: blocklistJSONFileLocation)!
        }
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
