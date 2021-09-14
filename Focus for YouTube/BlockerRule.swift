typealias SwiftyRule = [String: Any]

enum actionTypes: String {
    case block = "block"
    case blockCookies = "block-cookies"
    case CSSDisplayNone = "css-display-none"
    case ignorePreviousRules = "ignore-previous-rules"
    case makeHTTPS = "make-https"
}

enum triggerTypes: String {
    case urlFilter = "url-filter"
    case caseSensitive = "url-filter-is-case-sensitive"
    case ifDomain = "if-domain"
    case unlessDomain = "unless-domain"
    case resourceType = "resource-type"
    case loadType = "load-type"
    case ifTopURL = "if-top-url"
    case unlessTopURL = "unless-top-url"
}

struct BlockerRule {
    var triggers: [triggerTypes: Any] {
        didSet {
            printTriggerValidity()
        }
    }
    var actionType: actionTypes {
        didSet {
            printActionValidity()
        }
    }
    var selector: String? {
        didSet {
            printSelectorValidity()
            printActionValidity()
        }
    }
    
    init(triggers: [triggerTypes: Any], actionType: actionTypes, selector: String) {
        self.triggers = triggers
        self.actionType = actionType
        self.selector = selector
        printSelectorValidity()
        printTriggerValidity()
        printActionValidity()
    }
    
    init(triggers: [triggerTypes: Any], actionType: actionTypes) {
        self.triggers = triggers
        self.actionType = actionType
        printSelectorValidity()
        printTriggerValidity()
        printActionValidity()
    }
    
    init(selector: String) {
        self.init(triggers: [triggerTypes.urlFilter: "https?://www.youtube.com.*"], actionType: actionTypes.CSSDisplayNone, selector: selector)
    }
    
    func printSelectorValidity() {
        let numberOfOpenSquareBraces = self.selector?.filter { $0 == "[" }.count
        let numberOfCloseSquareBraces = self.selector?.filter { $0 == "]" }.count
        let numberOfSingleQuotes = self.selector?.filter { $0 == "'"}.count
        if numberOfOpenSquareBraces != numberOfCloseSquareBraces {
            print("Selectors must contain an equal number of opening and closing square braces: \(selector ?? "")")
        }
        if (numberOfSingleQuotes ?? 0 % 2) == 1 {
            print("Selectors must contain an equal number of opening and closing single quotes: \(selector ?? "")")
        }
    }

    func printTriggerValidity() {
        let triggerNames = self.triggers.keys
        if triggerNames.contains(.ifDomain) && triggerNames.contains(.unlessDomain) {
            print("A rule may use either the if-domain trigger or the unless-domain trigger, not both")
        }
        if triggerNames.contains(.ifTopURL) && triggerNames.contains(.unlessTopURL) {
            print("A rule may use either the if-top-url trigger or the unless-top-url trigger, not both")
        }
        if !triggerNames.contains(.urlFilter) {
            print("A trigger dictionary must include a url-filter key")
        }
    }
    
    // This is based on Apple's documentation for the content blocking API. This is for bug-proofing to ensure the rule set is valid.
    func printActionValidity() {
        if actionType == actionTypes.CSSDisplayNone && selector == nil {
            print("Selector is required for action of type css-display-none")
        }
    }

    func asSwiftyRule() -> SwiftyRule {
        var action: SwiftyRule
        if let selector = self.selector {
            action = ["type": actionType.rawValue, "selector": selector]
        } else {
            action = ["type": actionType.rawValue]
        }

        var triggers = [String: Any]()
        for (triggerType, value) in self.triggers {
            triggers[triggerType.rawValue] = value
        }

        return ["trigger": triggers, "action": action]
    }
}
