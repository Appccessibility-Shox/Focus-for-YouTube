//
//  SafariExtensionViewController.swift
//  Extension
//
//  Created by Patrick Botros on 2/5/21.
//  Copyright © 2021 Patrick Botros. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
