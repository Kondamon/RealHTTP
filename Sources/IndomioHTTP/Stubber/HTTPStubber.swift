//
//  IndomioHTTP
//
//  Created by the Mobile Team @ ImmobiliareLabs
//  Email: mobile@immobiliare.it
//  Web: http://labs.immobiliare.it
//
//  Copyright ©2021 Immobiliare.it SpA. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

public class HTTPStubber {
    
    // MARK: - Public Properties
    
    /// Singleton instance.
    public static var shared = HTTPStubber()
    
    /// Is the stubber running and intercepting request?
    public private(set) var isEnabled = false
    
    /// The mode defines how unknown URLs are handled.
    /// Defaults to `optout` which means requests without a mock will fail.
    public var unhandledMode: UnhandledMode = .optout
    
    /// Currently registered stub requests.
    public private(set) var stubbedRequests = [HTTPStubRequest]()
    
    /// List of ignore rules. Any triggered request which is matched
    /// will be ignored by the stub engine.
    public private(set) var ignoreRules = [HTTPStubIgnoreRule]()

    // MARK: - Private Properties
    
    private var registeredHooks: [HTTPStubberHook] = []
    private let queue = DispatchQueue(label: "httpstubber.queue.concurrent", attributes: .concurrent)

    // MARK: - Initialization
    
    private init() {
        registerHook(URLSessionHook())
    }
    
    // MARK: - Enable/Disable Stubber
        
    /// Start intercepting http requests.
    public func enable() {
        guard isEnabled == false else { return }
        
        // Load registered hooks
        registeredHooks.forEach {
            $0.load()
        }
        
        isEnabled = true
    }
    
    /// Stop intercepting the requests.
    public func disable() {
        guard isEnabled else { return }
        
        registeredHooks.forEach {
            $0.unload()
        }
        
        isEnabled = false
    }
    
    // MARK: - Manage Stubbed Requests
    
    /// Add a new stubbed request.
    /// No duplicates are allowed, existing instances will be replaced.
    ///
    /// - Parameter request: request to add.
    /// - Returns: Self
    public func add(stub request: HTTPStubRequest) -> Self {
        remove(stub: request)
        stubbedRequests.append(request)
        return self
    }
    
    /// Add new ignore rule.
    ///
    /// - Parameter rule: rule.
    /// - Returns: Self
    public func add(ignore rule: HTTPStubIgnoreRule) -> Self {
        ignoreRules.append(rule)
        return self
    }
    
    /// Remove an existing stub request.
    ///
    /// - Parameter request: request to remove.
    public func remove(stub request: HTTPStubRequest) {
        if let index = stubbedRequests.firstIndex(of: request) {
            stubbedRequests.remove(at: index)
        }
    }
    
    /// Remove an ignore rule.
    ///
    /// - Parameter rule: rule to remove.
    public func remove(ignore rule: HTTPStubIgnoreRule) {
        if let index = ignoreRules.firstIndex(of: rule) {
            ignoreRules.remove(at: index)
        }
    }
    
    /// Remove all registered stubs.
    public func removeAllStubs() {
        stubbedRequests.removeAll()
    }
    
    /// Remove all registered ignore rules.
    public func removeAllIgnoreRules() {
        ignoreRules.removeAll()
    }
    
    // MARK: - Register/Unregister Hooks
    
    /// Register a new hook.
    ///
    /// - Parameter hook: hook to register.
    public func registerHook(_ hook: HTTPStubberHook) {
        guard isHookRegistered(hook) == false else {
            return
        }
        
        registeredHooks.append(hook)
    }
    
    /// Return `true` if hook is already registered.
    ///
    /// - Parameter hook: hook to check.
    /// - Returns: Bool
    private func isHookRegistered(_ hook: HTTPStubberHook) -> Bool {
        registeredHooks.first(where: { $0 == hook }) != nil
    }
    
    // MARK: - Internal Functions
    
    /// Return suitable request which can manage the url request passed.
    ///
    /// - Parameter request: url request to check.
    /// - Returns: HTTPSubRequest?
    internal func suitableStubForRequest(_ request: URLRequest) -> HTTPStubRequest? {
        stubbedRequests.first {
            $0.match(request)
        }
    }
    
    /// Return `true` if request should be handled by the stubber.
    ///
    /// - Parameter request: request to check.
    /// - Returns: Bool
    public func shouldHandle(_ request: URLRequest) -> Bool {
        switch unhandledMode {
        case .optin:
            return suitableStubForRequest(request) != nil
        case .optout:
            return queue.sync {
                !ignoreRules.contains(where: {
                    $0.matches(request)
                })
            }
        }
    }
    
}

// MARK: - HTTPStubber.UnhandledMode

extension HTTPStubber {
    
    /// The mode defines how unknown URLs are handled.
    /// 
    /// - `optout`: only URLs registered wich matches the matchers are ignored for mocking.
    ///             - Registered mocked URL: mocked.
    ///             - Registered ignored URL: ignored by the stubber, default process is applied as if the stubber is disabled.
    ///             - Any other URL: Raises an error.
    /// - `optin`: Only registered mocked URLs are mocked, all others pass through.
    ///             - Registered mocked URL: mocked.
    ///             - Any other URL: ignored by the stubber, default process is applied as if the stubber is disabled.
    public enum UnhandledMode {
        case optout
        case optin
    }
    
}
