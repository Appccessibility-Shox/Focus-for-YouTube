//
//  SafariExtensionHandler.swift
//  Extension
//
//  Created by Patrick Botros on 2/5/21.
//  Copyright © 2021 Patrick Botros. All rights reserved.
//

import SafariServices

let defaults = UserDefaults.init(suiteName: "L27L4K8SQU.shockerella")
let contentBlockerID: String = "shockerella.Focus-for-YouTube.Content-Blocker"


class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        defaults!.register(defaults: ["active": true])
        defaults!.set(!defaults!.bool(forKey: "active"), forKey: "active")
        print(defaults?.bool(forKey: "active"))
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerID, completionHandler: { error in
            print(error ?? "🔄 Blocker reload success.")
        })
    }

}
